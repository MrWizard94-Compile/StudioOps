# Janus job transform + BLACKBOARD projection from .aether tasks.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function ConvertTo-WpaiDelegationPlan {
    <#
    .SYNOPSIS
      Transform janus_job intent document to live DelegationPlanSchema shape (plan.ts).
    #>
    param([Parameter(Mandatory)]$Job)

    $kind = [string](Get-WpaiJobField $Job 'kind')
    if ($kind -ne 'janus_job') { throw "kind must be janus_job, got: $kind" }

    $workload = [string](Get-WpaiJobField $Job 'workload')
    $objective = [string](Get-WpaiJobField $Job 'objective')
    $profile = [string](Get-WpaiJobField $Job 'validation_profile')
    if (-not $workload) { throw 'workload required' }
    if (-not $objective) { throw 'objective required' }
    if (-not $profile) { throw 'validation_profile required' }

    $files = @(Get-WpaiJobField $Job 'files_in_scope' @())
    $constraints = @(Get-WpaiJobField $Job 'constraints' @())
    $acceptance = @(Get-WpaiJobField $Job 'acceptance_criteria' @())
    $contextRefs = @(Get-WpaiJobField $Job 'context_refs' @('doc:claude'))
    if ($contextRefs -notcontains 'doc:claude') { $contextRefs = @('doc:claude') + $contextRefs }
    $patchMode = [string](Get-WpaiJobField $Job 'patch_mode' 'manual')
    if ($patchMode -notin @('manual', 'identity')) { $patchMode = 'manual' }

    $parentConstraints = @('Studio bridge created plan from janus_job') + $constraints

    $plan = [ordered]@{
        parent = [ordered]@{
            assignee           = 'claude'
            workload           = $null
            validation_profile = $profile
            context_refs       = @($contextRefs)
            spec               = [ordered]@{
                objective           = "Coordinate: $objective"
                constraints         = @($parentConstraints)
                files_in_scope      = @()
                acceptance_criteria = @('All children accepted')
            }
        }
        children = @(
            [ordered]@{
                assignee   = 'grok'
                patch_mode = $patchMode
                task       = [ordered]@{
                    workload           = $workload
                    validation_profile = $profile
                    context_refs       = @($contextRefs)
                    spec               = [ordered]@{
                        objective           = $objective
                        constraints         = @($constraints)
                        files_in_scope      = @($files)
                        acceptance_criteria = @($acceptance)
                    }
                }
            }
        )
        provision = [ordered]@{
            auto_worktree = $true
            auto_prepare  = $false
        }
    }
    return $plan
}

function Get-WpaiJobField {
    param($Job, [string]$Name, $Default = $null)
    if ($null -eq $Job) { return $Default }
    if ($Job -is [hashtable] -or $Job -is [System.Collections.IDictionary]) {
        if ($Job.Contains($Name)) { return $Job[$Name] }
        if ($Job.ContainsKey($Name)) { return $Job[$Name] }
        return $Default
    }
    $p = $Job.PSObject.Properties[$Name]
    if ($null -eq $p -or $null -eq $p.Value) { return $Default }
    return $p.Value
}

function Read-WpaiJanusJobFile {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { throw "Janus job file not found: $Path" }
    $raw = Get-Content -LiteralPath $Path -Raw -Encoding utf8
    if ($Path -match '\.json$') {
        return ($raw | ConvertFrom-Json)
    }
    # YAML front-matter between --- in markdown
    if ($raw -match '(?s)^---\s*\r?\n(.*?)\r?\n---') {
        $fm = $Matches[1]
        # minimal: expect JSON block in front matter or full JSON file
        if ($fm.Trim().StartsWith('{')) {
            return ($fm | ConvertFrom-Json)
        }
    }
    if ($raw.Trim().StartsWith('{')) {
        return ($raw | ConvertFrom-Json)
    }
    throw 'Handoff must be JSON janus_job or markdown with JSON front-matter'
}

function Invoke-WpaiJanusJobPlan {
    param(
        [Parameter(Mandatory)][string]$JobPath,
        [switch]$DryRun,
        [switch]$Submit
    )
    $cfg = Get-WpaiConfig
    $janusRoot = [string]$cfg.janus_root
    if (-not (Test-Path -LiteralPath (Join-Path $janusRoot 'janus.config.json'))) {
        throw "janus.config.json not found under janus_root: $janusRoot"
    }

    $job = Read-WpaiJanusJobFile -Path $JobPath
    $parentExisting = Get-WpaiJobField $job 'parent_task_id' $null
    if ($parentExisting) {
        return [pscustomobject]@{
            mode            = 'attach_existing'
            parent_task_id  = [string]$parentExisting
            plan_path       = $null
            submitted       = $false
            message         = 'Using existing parent_task_id; no new plan created'
        }
    }

    $plan = ConvertTo-WpaiDelegationPlan -Job $job
    $id = New-WpaiId
    $plansDir = [string](Get-WpaiConfigValue -Name 'wpai_dir' -Default 'C:\WPAI\Workspace\.wpai')
    $plansDir = Join-Path $plansDir 'plans'
    if (-not (Test-Path -LiteralPath $plansDir)) { New-Item -ItemType Directory -Force -Path $plansDir | Out-Null }
    $planPath = Join-Path $plansDir ("{0}-delegation.json" -f $id)
    Write-WpaiJsonAtomic -Path $planPath -Object $plan

    if ($DryRun -or -not $Submit) {
        return [pscustomobject]@{
            mode           = 'plan_written'
            parent_task_id = $null
            plan_path      = $planPath
            submitted      = $false
            plan           = $plan
            message        = 'DelegationPlan written; pass -Submit to invoke orchestrate plan'
        }
    }

    $cli = [string]$cfg.janus_cli
    if (-not $cli) { throw 'janus_cli not configured' }
    # Split "node path\to\bin.js"
    $parts = $cli -split '\s+', 2
    $exe = $parts[0]
    $bin = if ($parts.Count -gt 1) { $parts[1] } else { '' }
    $argList = @()
    if ($bin) { $argList += $bin }
    $argList += @('orchestrate', 'plan', '-f', $planPath)

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $exe
    $psi.Arguments = ($argList | ForEach-Object {
            if ($_ -match '\s') { '"{0}"' -f $_ } else { $_ }
        }) -join ' '
    $psi.WorkingDirectory = $janusRoot
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $p = [System.Diagnostics.Process]::Start($psi)
    $stdout = $p.StandardOutput.ReadToEnd()
    $stderr = $p.StandardError.ReadToEnd()
    $p.WaitForExit()
    $ok = $p.ExitCode -eq 0
    Write-WpaiLog -Name 'bridge' -Message ("orchestrate plan exit={0} plan={1}" -f $p.ExitCode, $planPath)

    return [pscustomobject]@{
        mode           = 'submitted'
        parent_task_id = $null
        plan_path      = $planPath
        submitted      = $ok
        exit_code      = $p.ExitCode
        stdout         = $stdout
        stderr         = $stderr
        message        = $(if ($ok) { 'orchestrate plan invoked' } else { 'orchestrate plan failed — see stderr' })
    }
}

function Sync-WpaiJanusProjection {
    param()
    $cfg = Get-WpaiConfig
    $tasksPath = [string]$cfg.aether_tasks_path
    $open = 0
    $failed = 0
    $parents = @()
    if (Test-Path -LiteralPath $tasksPath) {
        try {
            $raw = Get-Content -LiteralPath $tasksPath -Raw -Encoding utf8
            $data = $raw | ConvertFrom-Json
            $tasks = @()
            if ($data.PSObject.Properties['tasks']) {
                $tnode = $data.tasks
                if ($tnode -is [System.Collections.IDictionary] -or $tnode.PSObject.Properties.Name) {
                    foreach ($p in $tnode.PSObject.Properties) { $tasks += $p.Value }
                } elseif ($tnode -is [System.Collections.IEnumerable]) {
                    $tasks = @($tnode)
                }
            } elseif ($data -is [System.Collections.IEnumerable] -and -not ($data -is [string])) {
                $tasks = @($data)
            }
            foreach ($t in $tasks) {
                $st = [string](Get-WpaiJobField $t 'status' '')
                $pid = Get-WpaiJobField $t 'parent_id' $null
                if ($st -in @('pending', 'in_progress', 'validating')) { $open++ }
                if ($st -eq 'failed') { $failed++ }
                if (-not $pid -and $st -in @('pending', 'in_progress', 'validating', 'accepted')) {
                    $id = [string](Get-WpaiJobField $t 'id' '')
                    if ($id) { $parents += $id }
                }
            }
        } catch {
            Write-WpaiLog -Name 'bridge' -Message ("sync parse error: {0}" -f $_.Exception.Message)
        }
    }

    $bb = Invoke-WpaiBlackboardRmw -Mutator {
        param($bb)
        if ($bb['janus'] -isnot [System.Collections.IDictionary]) {
            $bb['janus'] = [ordered]@{}
        }
        $bb['janus']['cli_path'] = [string](Get-WpaiConfigValue -Name 'janus_cli' -Default '')
        $bb['janus']['open_tasks'] = $open
        $bb['janus']['failed_tasks'] = $failed
        $bb['janus']['parents'] = @($parents | Select-Object -First 20)
        $bb['janus']['last_loop'] = Get-WpaiUtcNow
        # promotions
        $cands = @()
        # inline count to avoid nested call issues
        $cutoff = [DateTime]::UtcNow.AddDays(-90)
        $counts = @{}
        if ($bb['events'] -is [System.Collections.IEnumerable]) {
            foreach ($e in $bb['events']) {
                $kind = if ($e -is [System.Collections.IDictionary]) { [string]$e['kind'] } else { [string](Get-WpaiJobField $e 'kind' '') }
                if ($kind -ne 'manual_step') { continue }
                $sk = if ($e -is [System.Collections.IDictionary]) { [string]$e['step_key'] } else { [string](Get-WpaiJobField $e 'step_key' '') }
                if (-not $sk) { continue }
                try {
                    $tsS = if ($e -is [System.Collections.IDictionary]) { [string]$e['ts'] } else { [string](Get-WpaiJobField $e 'ts' '') }
                    $ts = [DateTime]::Parse($tsS).ToUniversalTime()
                    if ($ts -lt $cutoff) { continue }
                } catch { continue }
                if (-not $counts.ContainsKey($sk)) { $counts[$sk] = 0 }
                $counts[$sk]++
            }
        }
        $promoKeys = @()
        foreach ($k in $counts.Keys) {
            if ($counts[$k] -ge 3) {
                Add-WpaiEvent -Blackboard $bb -Kind 'promotion_candidate' -StepKey $k -Actor 'bridge' -Refs @{ count = $counts[$k] }
                $promoKeys += $k
            }
        }
        # stash for bus notify after RMW
        $script:WpaiLastPromoKeys = $promoKeys
    }

    # Bus task to orchestrator for each promotion candidate (Director must ack before build)
    if ($script:WpaiLastPromoKeys) {
        foreach ($pk in @($script:WpaiLastPromoKeys)) {
            try {
                Write-WpaiBusMessage -Text ("promotion_candidate: $pk (>=3 manual steps / 90d) — Director ack to authorize Software automation") `
                    -Type 'task' -From 'bridge' -To 'orchestrator' | Out-Null
            } catch { }
        }
    }

    try {
        Write-WpaiBusMessage -Text ("blackboard_sync gen={0} open={1}" -f $bb.generation, $open) `
            -Type 'blackboard_sync' -From 'bridge' -To 'all' -Path (Get-WpaiConfigValue -Name 'blackboard_path') | Out-Null
    } catch { }

    return [pscustomobject]@{
        open_tasks   = $open
        failed_tasks = $failed
        parents      = $parents
        generation   = $bb.generation
        updated_at   = $bb.updated_at
        promotions   = @($script:WpaiLastPromoKeys)
    }
}
