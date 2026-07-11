<#
.SYNOPSIS
  HellForge Council bus CLI — Protocol v2 (short bus + disk handoffs).

.DESCRIPTION
  Shared control plane for Claude (orchestrator) and Grok (executor).

  Bus:      C:\WPAI\Workspace\.hellforge\bus.jsonl   (short control messages)
  Status:   C:\WPAI\Workspace\.hellforge\STATUS.md
  Handoffs: C:\WPAI\Workspace\.hellforge\handoffs\
  Protocol: C:\WPAI\Workspace\.hellforge\PROTOCOL.md

  Dot-source:
    $env:HF_ROLE = "executor"   # or orchestrator
    . C:\WPAI\Software\StudioOps\cli\hf-bus.ps1

  Commands:
    hf-say "one-line chat"
    hf-bus ping|task|handoff|ack|done|block|status|board|inbox|tail|watch|export|help

.NOTES
  Part of WPAI StudioOps. Human-directed, AI-assisted.
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet(
        'say', 'tail', 'watch', 'status', 'export', 'help', '',
        'ping', 'task', 'handoff', 'ack', 'done', 'block', 'board', 'inbox', 'protocol',
        'approve_request', 'approve_result', 'budget', 'kill', 'blackboard_sync'
    )]
    [string]$Command = '',

    [Parameter(ValueFromRemainingArguments = $true)]
    [object[]]$Rest
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:HfBusDefaultDir = 'C:\WPAI\Workspace\.hellforge'
$script:HfBusDefaultPath = 'C:\WPAI\Workspace\.hellforge\bus.jsonl'
$script:HfHandoffsDir = 'C:\WPAI\Workspace\.hellforge\handoffs'
$script:HfInboxDir = 'C:\WPAI\Workspace\.hellforge\inbox'
$script:HfStatusPath = 'C:\WPAI\Workspace\.hellforge\STATUS.md'
$script:HfProtocolPath = 'C:\WPAI\Workspace\.hellforge\PROTOCOL.md'

function Get-HfBusPath {
    param([string]$Path)
    if ($Path) { return $Path }
    if ($env:HF_BUS) { return $env:HF_BUS }
    return $script:HfBusDefaultPath
}

function Ensure-HfCouncilDirs {
    foreach ($d in @($script:HfBusDefaultDir, $script:HfHandoffsDir, $script:HfInboxDir)) {
        if (-not (Test-Path -LiteralPath $d)) {
            New-Item -ItemType Directory -Force -Path $d | Out-Null
        }
    }
    $bus = Get-HfBusPath
    if (-not (Test-Path -LiteralPath $bus)) {
        New-Item -ItemType File -Force -Path $bus | Out-Null
    }
    foreach ($r in @('orchestrator', 'executor', 'director', 'all')) {
        $p = Join-Path $script:HfInboxDir "$r.jsonl"
        if (-not (Test-Path -LiteralPath $p)) {
            New-Item -ItemType File -Force -Path $p | Out-Null
        }
    }
}

function Ensure-HfBus {
    param([string]$Path)
    Ensure-HfCouncilDirs
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType File -Force -Path $Path | Out-Null
    }
}

function Resolve-HfRole {
    param([string]$From)
    if ($From) { return $From.ToLowerInvariant() }
    if ($env:HF_ROLE) { return $env:HF_ROLE.ToLowerInvariant() }
    $globalRole = Get-Variable -Name HF_ROLE -Scope Global -ErrorAction SilentlyContinue
    if ($null -ne $globalRole -and $null -ne $globalRole.Value -and [string]$globalRole.Value -ne '') {
        return ([string]$globalRole.Value).ToLowerInvariant()
    }
    return 'executor'
}

function New-HfId {
    return ([guid]::NewGuid().ToString('N').Substring(0, 8))
}

function New-HfBusMessage {
    param(
        [Parameter(Mandatory)][string]$Text,
        [string]$From,
        [string]$To = 'all',
        [string]$Path,
        [string]$Type = 'chat',
        [string]$Id,
        [string]$Ref,
        [string]$FilePath
    )
    $bus = Get-HfBusPath -Path $Path
    Ensure-HfBus -Path $bus
    $role = Resolve-HfRole -From $From
    $to = if ($To) { $To.ToLowerInvariant() } else { 'all' }
    $text = ($Text -replace "`r`n", ' ' -replace "`n", ' ').Trim()
    if ([string]::IsNullOrWhiteSpace($text)) {
        throw 'Message text is required.'
    }
    # Keep bus lines monitor-friendly (PROTOCOL v2: 400 chars non-chat)
    if ($text.Length -gt 400 -and $Type -ne 'chat') {
        $text = $text.Substring(0, 397) + '...'
    }

    $obj = [ordered]@{
        ts   = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
        from = $role
        to   = $to
        type = if ($Type) { $Type.ToLowerInvariant() } else { 'chat' }
        text = $text
    }
    if ($Id) { $obj['id'] = $Id }
    elseif ($Type -in @('task', 'handoff', 'done', 'block', 'approve_request', 'approve_result', 'budget', 'kill', 'blackboard_sync')) {
        $obj['id'] = New-HfId
    }
    if ($Ref) { $obj['ref'] = $Ref }
    if ($FilePath) { $obj['path'] = $FilePath }

    $line = ($obj | ConvertTo-Json -Compress -Depth 6)
    Add-Content -LiteralPath $bus -Value $line -Encoding utf8

    # Mirror into directed inboxes
    foreach ($box in @($to, 'all')) {
        if ($box -eq 'all' -and $to -ne 'all') {
            # still mirror to all inbox for visibility
        }
        $inbox = Join-Path $script:HfInboxDir "$box.jsonl"
        try {
            Add-Content -LiteralPath $inbox -Value $line -Encoding utf8
        } catch {
            # non-fatal
        }
    }
    if ($to -ne 'all') {
        # also ensure sender keeps a copy? skip — bus is source of truth
    }

    return [pscustomobject]$obj
}

function Read-HfBus {
    param(
        [string]$Path,
        [int]$Count = 0,
        [string]$From,
        [string]$To,
        [string]$Contains,
        [string]$Type
    )
    $bus = Get-HfBusPath -Path $Path
    if (-not (Test-Path -LiteralPath $bus)) { return @() }

    $messages = @()
    foreach ($line in Get-Content -LiteralPath $bus -Encoding utf8 -ErrorAction SilentlyContinue) {
        $trim = $line.Trim()
        if (-not $trim) { continue }
        try {
            $m = $trim | ConvertFrom-Json
        } catch {
            continue
        }
        $textProp = $m.PSObject.Properties['text']
        $fromProp = $m.PSObject.Properties['from']
        $toProp = $m.PSObject.Properties['to']
        $tsProp = $m.PSObject.Properties['ts']
        $typeProp = $m.PSObject.Properties['type']
        $idProp = $m.PSObject.Properties['id']
        $refProp = $m.PSObject.Properties['ref']
        $pathProp = $m.PSObject.Properties['path']
        if ($null -eq $textProp -or [string]::IsNullOrWhiteSpace([string]$textProp.Value)) { continue }
        $fromVal = if ($null -ne $fromProp) { [string]$fromProp.Value } else { '' }
        $toVal = if ($null -ne $toProp) { [string]$toProp.Value } else { '' }
        $textVal = [string]$textProp.Value
        $tsVal = 0
        if ($null -ne $tsProp -and $null -ne $tsProp.Value) {
            try { $tsVal = [int64]$tsProp.Value } catch { $tsVal = 0 }
        }
        $typeVal = if ($null -ne $typeProp -and $typeProp.Value) { [string]$typeProp.Value } else { 'chat' }
        if ($From -and $fromVal -ne $From) { continue }
        if ($To -and $toVal -ne $To) { continue }
        if ($Type -and $typeVal -ne $Type) { continue }
        if ($Contains) {
            $blob = ('{0} {1} {2} {3}' -f $fromVal, $toVal, $typeVal, $textVal)
            if ($blob.IndexOf($Contains, [StringComparison]::OrdinalIgnoreCase) -lt 0) { continue }
        }
        $idVal = $null
        if ($null -ne $idProp -and $null -ne $idProp.Value) { $idVal = [string]$idProp.Value }
        $refVal = $null
        if ($null -ne $refProp -and $null -ne $refProp.Value) { $refVal = [string]$refProp.Value }
        $pathVal = $null
        if ($null -ne $pathProp -and $null -ne $pathProp.Value) { $pathVal = [string]$pathProp.Value }
        $messages += [pscustomobject]@{
            ts   = $tsVal
            from = $fromVal
            to   = $toVal
            type = $typeVal
            id   = $idVal
            ref  = $refVal
            path = $pathVal
            text = $textVal
        }
    }

    if ($Count -gt 0 -and $messages.Count -gt $Count) {
        return @($messages | Select-Object -Last $Count)
    }
    return $messages
}

function Get-HfProp {
    param($Object, [string]$Name, $Default = $null)
    if ($null -eq $Object) { return $Default }
    $p = $Object.PSObject.Properties[$Name]
    if ($null -eq $p -or $null -eq $p.Value) { return $Default }
    return $p.Value
}

function Format-HfBusMessage {
    param($Message, [switch]$IsoTime)
    if (-not $Message) { return '' }
    $when = ''
    try {
        $ts = Get-HfProp $Message 'ts' 0
        $dto = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$ts).ToLocalTime()
        $when = if ($IsoTime) { $dto.ToString('yyyy-MM-dd HH:mm:ss') } else { $dto.ToString('HH:mm:ss') }
    } catch {
        $when = '?'
    }
    $type = [string](Get-HfProp $Message 'type' 'chat')
    $id = Get-HfProp $Message 'id' $null
    $ref = Get-HfProp $Message 'ref' $null
    $filePath = Get-HfProp $Message 'path' $null
    $idBit = if ($id) { " id=$id" } else { '' }
    $refBit = if ($ref) { " ref=$ref" } else { '' }
    $pathBit = if ($filePath) { " path=$filePath" } else { '' }
    $from = [string](Get-HfProp $Message 'from' '')
    $to = [string](Get-HfProp $Message 'to' '')
    $text = [string](Get-HfProp $Message 'text' '')
    return ('[{0}] {1} -> {2} ({3}{4}{5}) | {6}{7}' -f $when, $from, $to, $type, $idBit, $refBit, $text, $pathBit)
}

function Export-HfBusMarkdown {
    param(
        [string]$Path,
        [Parameter(Mandatory)][string]$OutFile,
        [int]$Count = 0
    )
    $msgs = @(Read-HfBus -Path $Path -Count $Count)
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine('# HellForge Council Bus Export')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine(('_Generated {0:u} · {1} message(s)_' -f (Get-Date).ToUniversalTime(), $msgs.Count))
    [void]$sb.AppendLine('')
    foreach ($m in $msgs) {
        $when = try {
            [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$m.ts).ToLocalTime().ToString('yyyy-MM-dd HH:mm:ss')
        } catch { 'unknown' }
        [void]$sb.AppendLine(('## {0} → {1} ({2})' -f $m.from, $m.to, $m.type))
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine(('- **When:** {0}' -f $when))
        if ($m.id) { [void]$sb.AppendLine(('- **id:** `{0}`' -f $m.id)) }
        if ($m.ref) { [void]$sb.AppendLine(('- **ref:** `{0}`' -f $m.ref)) }
        if ($m.path) { [void]$sb.AppendLine(('- **path:** `{0}`' -f $m.path)) }
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine($m.text)
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine('---')
        [void]$sb.AppendLine('')
    }
    $dir = Split-Path -Parent $OutFile
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    Set-Content -LiteralPath $OutFile -Value $sb.ToString() -Encoding utf8
    return $OutFile
}

function Get-HfBusStatus {
    param([string]$Path)
    Ensure-HfCouncilDirs
    $bus = Get-HfBusPath -Path $Path
    $msgs = @(Read-HfBus -Path $bus)
    $byFrom = @{}
    $byType = @{}
    foreach ($m in $msgs) {
        $f = [string](Get-HfProp $m 'from' 'unknown')
        if (-not $byFrom.ContainsKey($f)) { $byFrom[$f] = 0 }
        $byFrom[$f]++
        $t = [string](Get-HfProp $m 'type' 'chat')
        if (-not $byType.ContainsKey($t)) { $byType[$t] = 0 }
        $byType[$t]++
    }
    $last = if ($msgs.Count -gt 0) { $msgs[-1] } else { $null }
    $info = Get-Item -LiteralPath $bus -ErrorAction SilentlyContinue
    $handoffs = @(Get-ChildItem -LiteralPath $script:HfHandoffsDir -File -ErrorAction SilentlyContinue)
    [pscustomobject]@{
        Path          = $bus
        Exists         = [bool]$info
        Bytes          = if ($info) { $info.Length } else { 0 }
        Messages       = $msgs.Count
        ByRole         = ($byFrom.GetEnumerator() | Sort-Object Name | ForEach-Object { '{0}={1}' -f $_.Key, $_.Value }) -join ', '
        ByType         = ($byType.GetEnumerator() | Sort-Object Name | ForEach-Object { '{0}={1}' -f $_.Key, $_.Value }) -join ', '
        Handoffs       = $handoffs.Count
        StatusPath     = $script:HfStatusPath
        ProtocolPath   = $script:HfProtocolPath
        LastFrom       = if ($last) { Get-HfProp $last 'from' $null } else { $null }
        LastTo         = if ($last) { Get-HfProp $last 'to' $null } else { $null }
        LastType       = if ($last) { Get-HfProp $last 'type' $null } else { $null }
        LastText       = if ($last) { Get-HfProp $last 'text' $null } else { $null }
        LastFormatted  = if ($last) { Format-HfBusMessage -Message $last -IsoTime } else { '(empty)' }
    }
}

function Watch-HfBus {
    param(
        [string]$Path,
        [string]$From,
        [string]$To
    )
    $bus = Get-HfBusPath -Path $Path
    Ensure-HfBus -Path $bus
    Write-Host ("Watching {0} (Ctrl+C to stop)" -f $bus) -ForegroundColor DarkYellow
    Get-Content -LiteralPath $bus -Wait -Tail 0 -Encoding utf8 | ForEach-Object {
        $trim = $_.Trim()
        if (-not $trim) { return }
        try {
            $m = $trim | ConvertFrom-Json
        } catch {
            Write-Host ("[raw] {0}" -f $trim) -ForegroundColor DarkGray
            return
        }
        $obj = [pscustomobject]@{
            ts   = [int64]$m.ts
            from = [string]$m.from
            to   = [string]$m.to
            type = if ($m.PSObject.Properties['type']) { [string]$m.type } else { 'chat' }
            id   = if ($m.PSObject.Properties['id']) { [string]$m.id } else { $null }
            ref  = if ($m.PSObject.Properties['ref']) { [string]$m.ref } else { $null }
            path = if ($m.PSObject.Properties['path']) { [string]$m.path } else { $null }
            text = [string]$m.text
        }
        if ($From -and $obj.from -ne $From) { return }
        if ($To -and $obj.to -ne $To) { return }
        Write-Host (Format-HfBusMessage -Message $obj -IsoTime)
    }
}

function Write-HfHandoffFile {
    param(
        [Parameter(Mandatory)][string]$Title,
        [string]$Body,
        [string]$SourceFile,
        [string]$From
    )
    Ensure-HfCouncilDirs
    $role = Resolve-HfRole -From $From
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $safe = ($Title -replace '[^\w\- ]', '' -replace '\s+', '-').Trim('-').ToLowerInvariant()
    if (-not $safe) { $safe = 'handoff' }
    if ($safe.Length -gt 40) { $safe = $safe.Substring(0, 40) }
    $name = '{0}-{1}-{2}.md' -f $stamp, $role, $safe
    $dest = Join-Path $script:HfHandoffsDir $name

    if ($SourceFile) {
        if (-not (Test-Path -LiteralPath $SourceFile)) {
            throw "Source file not found: $SourceFile"
        }
        $content = Get-Content -LiteralPath $SourceFile -Raw -Encoding utf8
    } else {
        $content = $Body
    }
    if ([string]::IsNullOrWhiteSpace($content)) {
        throw 'Handoff body or -File is required.'
    }

    $header = @(
        "# Handoff: $Title"
        ""
        "- **From:** $role"
        "- **When:** $((Get-Date).ToString('u'))"
        "- **Id file:** $name"
        ""
        "---"
        ""
    ) -join "`n"
    # Avoid double header if body already starts with #
    $final = if ($content.TrimStart().StartsWith('# Handoff:')) { $content } else { $header + $content.TrimEnd() + "`n" }
    Set-Content -LiteralPath $dest -Value $final -Encoding utf8
    return $dest
}

function hf-say {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Message,
        [string]$To = 'all',
        [string]$From,
        [string]$Path,
        [string]$Type = 'chat',
        [string]$Id,
        [string]$Ref,
        [string]$FilePath
    )
    $posted = New-HfBusMessage -Text $Message -To $To -From $From -Path $Path -Type $Type -Id $Id -Ref $Ref -FilePath $FilePath
    Write-Host (Format-HfBusMessage -Message $posted -IsoTime) -ForegroundColor DarkYellow
    return $posted
}

function hf-bus {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [ValidateSet(
            'say', 'tail', 'watch', 'status', 'export', 'help',
            'ping', 'task', 'handoff', 'ack', 'done', 'block', 'board', 'inbox', 'protocol',
            'approve_request', 'approve_result', 'budget', 'kill', 'blackboard_sync'
        )]
        [string]$Command = 'help',

        [Alias('m', 'Text')]
        [string]$Message,

        [string]$To = 'all',
        [string]$From,
        [string]$Path,
        [Alias('n')]
        [int]$Count = 20,
        [string]$Contains,
        [string]$OutFile,
        [string]$Type,
        [string]$Title,
        [string]$Body,
        [string]$File,
        [Alias('Ref', 'r')]
        [string]$Id
    )

    Ensure-HfCouncilDirs
    $me = Resolve-HfRole -From $From

    switch ($Command) {
        'say' {
            if (-not $Message) { throw 'hf-bus say requires -Message' }
            hf-say -Message $Message -To $To -From $From -Path $Path -Type 'chat' | Out-Null
        }
        'ping' {
            $msg = if ($Message) { $Message } else { "ping — $me online (protocol v2)" }
            hf-say -Message $msg -To $To -From $From -Path $Path -Type 'ping' | Out-Null
        }
        'task' {
            if (-not $Message) { throw 'hf-bus task requires -Message' }
            $posted = hf-say -Message $Message -To $To -From $From -Path $Path -Type 'task'
            $tid = Get-HfProp $posted 'id' '?'
            Write-Host ("  task id={0} — peer should: hf-bus ack -Id {0}" -f $tid) -ForegroundColor DarkGray
        }
        'handoff' {
            if (-not $Title) { $Title = 'Handoff' }
            if (-not $File -and -not $Body -and $Message) { $Body = $Message }
            $dest = Write-HfHandoffFile -Title $Title -Body $Body -SourceFile $File -From $From
            $summary = if ($Message) { $Message } else { "Handoff: $Title" }
            $posted = hf-say -Message $summary -To $To -From $From -Path $Path -Type 'handoff' -FilePath $dest
            $hid = Get-HfProp $posted 'id' '?'
            Write-Host ("  wrote {0}" -f $dest) -ForegroundColor Green
            Write-Host ("  handoff id={0}" -f $hid) -ForegroundColor DarkGray
        }
        'ack' {
            if (-not $Id -and -not $Message) { throw 'hf-bus ack requires -Id (ref) and/or -Message' }
            $msg = if ($Message) { $Message } else { "ack $Id" }
            hf-say -Message $msg -To $To -From $From -Path $Path -Type 'ack' -Ref $Id | Out-Null
        }
        'done' {
            if (-not $Message) { $Message = if ($Id) { "done ref=$Id" } else { 'done' } }
            hf-say -Message $Message -To $To -From $From -Path $Path -Type 'done' -Ref $Id | Out-Null
        }
        'block' {
            if (-not $Message) { throw 'hf-bus block requires -Message' }
            hf-say -Message $Message -To $To -From $From -Path $Path -Type 'block' | Out-Null
        }
        'approve_request' {
            if (-not $Message) { throw 'hf-bus approve_request requires -Message' }
            if (-not $File) { throw 'hf-bus approve_request requires -File path to ticket' }
            hf-say -Message $Message -To $To -From $From -Path $Path -Type 'approve_request' -FilePath $File | Out-Null
        }
        'approve_result' {
            if (-not $Message) { throw 'hf-bus approve_result requires -Message' }
            hf-say -Message $Message -To $To -From $From -Path $Path -Type 'approve_result' -FilePath $File -Ref $Id | Out-Null
        }
        'budget' {
            if (-not $Message) { throw 'hf-bus budget requires -Message' }
            hf-say -Message $Message -To $To -From $From -Path $Path -Type 'budget' | Out-Null
        }
        'kill' {
            if (-not $Message) { throw 'hf-bus kill requires -Message' }
            hf-say -Message $Message -To $To -From $From -Path $Path -Type 'kill' | Out-Null
        }
        'blackboard_sync' {
            $msg = if ($Message) { $Message } else { 'blackboard_sync' }
            hf-say -Message $msg -To $To -From $From -Path $Path -Type 'blackboard_sync' -FilePath $File | Out-Null
        }
        'board' {
            if (Test-Path -LiteralPath $script:HfStatusPath) {
                Get-Content -LiteralPath $script:HfStatusPath -Encoding utf8
            } else {
                Write-Host "No STATUS.md yet at $script:HfStatusPath" -ForegroundColor Yellow
            }
        }
        'inbox' {
            $role = $me
            $msgs = @(Read-HfBus -Path $Path -Count $Count | Where-Object {
                $_.to -eq $role -or $_.to -eq 'all' -or $_.from -eq $role
            })
            if ($Type) { $msgs = @($msgs | Where-Object { $_.type -eq $Type }) }
            if ($Contains) {
                $msgs = @($msgs | Where-Object {
                    ("$($_.text) $($_.path) $($_.type)").IndexOf($Contains, [StringComparison]::OrdinalIgnoreCase) -ge 0
                })
            }
            foreach ($m in $msgs) {
                Write-Output (Format-HfBusMessage -Message $m -IsoTime)
            }
        }
        'protocol' {
            if (Test-Path -LiteralPath $script:HfProtocolPath) {
                Get-Content -LiteralPath $script:HfProtocolPath -Encoding utf8
            } else {
                Write-Host "Missing $script:HfProtocolPath" -ForegroundColor Yellow
            }
        }
        'tail' {
            $msgs = @(Read-HfBus -Path $Path -Count $Count -From $From -To $To -Contains $Contains -Type $Type)
            # when -From used as filter on tail, don't confuse with sender — Read-HfBus uses From as filter which is correct for tail
            foreach ($m in $msgs) {
                Write-Output (Format-HfBusMessage -Message $m -IsoTime)
            }
        }
        'watch' {
            Watch-HfBus -Path $Path -From $From -To $To
        }
        'status' {
            $s = Get-HfBusStatus -Path $Path
            Write-Output ("Path:       {0}" -f $s.Path)
            Write-Output ("Messages:   {0}  ({1} bytes)" -f $s.Messages, $s.Bytes)
            Write-Output ("By role:    {0}" -f $(if ($s.ByRole) { $s.ByRole } else { '(none)' }))
            Write-Output ("By type:    {0}" -f $(if ($s.ByType) { $s.ByType } else { '(none)' }))
            Write-Output ("Handoffs:   {0} in {1}" -f $s.Handoffs, $script:HfHandoffsDir)
            Write-Output ("STATUS:     {0}" -f $s.StatusPath)
            Write-Output ("Protocol:   {0}" -f $s.ProtocolPath)
            Write-Output ("Your role:  {0}" -f $me)
            Write-Output ("Last:       {0}" -f $s.LastFormatted)
        }
        'export' {
            if (-not $OutFile) {
                $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
                $OutFile = Join-Path $script:HfBusDefaultDir ("exports\bus-{0}.md" -f $stamp)
            }
            $written = Export-HfBusMarkdown -Path $Path -OutFile $OutFile -Count $Count
            Write-Output ("Exported -> {0}" -f $written)
        }
        default {
            @"
HellForge Council CLI — Protocol v2

  Dot-source:  `$env:HF_ROLE = 'executor'   # or orchestrator
               . C:\WPAI\Software\StudioOps\cli\hf-bus.ps1

  SHORT BUS (prefer one line):
    hf-say "message" [-To orchestrator]
    hf-bus ping [-To all]
    hf-bus task -To orchestrator -Message "do X"
    hf-bus ack -Id <taskId> -Message "got it"
    hf-bus done -Id <taskId> -Message "shipped"
    hf-bus block -Message "need Y"

  DISK PAYLOADS:
    hf-bus handoff -To orchestrator -Title "Title" -File C:\path\doc.md
    hf-bus handoff -To all -Title "Note" -Body "markdown body..."
    hf-bus board                 # print STATUS.md
    hf-bus protocol              # print PROTOCOL.md

  READ:
    hf-bus inbox [-Count 30]     # traffic for your role + all
    hf-bus tail [-Count 20] [-Type handoff]
    hf-bus status
    hf-bus watch
    hf-bus export

  Paths:
    Bus       C:\WPAI\Workspace\.hellforge\bus.jsonl
    STATUS    C:\WPAI\Workspace\.hellforge\STATUS.md
    Handoffs  C:\WPAI\Workspace\.hellforge\handoffs\
    Protocol  C:\WPAI\Workspace\.hellforge\PROTOCOL.md

  Rule: bus = telegram (short). Disk handoffs = mail (long).
"@
        }
    }
}

# --- Script entry / direct invoke ---
function ConvertFrom-HfRestArgs {
    param([object[]]$RestArgs, [string]$Cmd)
    $invokeParams = @{ Command = $Cmd }
    $argsList = @()
    if ($null -ne $RestArgs) { $argsList = @($RestArgs) }
    for ($i = 0; $i -lt $argsList.Count; $i++) {
        $tok = [string]$argsList[$i]
        if ($tok -match '^-Message$|^-m$|^-Text$') {
            if ($i + 1 -lt $argsList.Count) { $invokeParams.Message = [string]$argsList[++$i] }
            continue
        }
        if ($tok -match '^-To$') {
            if ($i + 1 -lt $argsList.Count) { $invokeParams.To = [string]$argsList[++$i] }
            continue
        }
        if ($tok -match '^-From$') {
            if ($i + 1 -lt $argsList.Count) { $invokeParams.From = [string]$argsList[++$i] }
            continue
        }
        if ($tok -match '^-Path$') {
            if ($i + 1 -lt $argsList.Count) { $invokeParams.Path = [string]$argsList[++$i] }
            continue
        }
        if ($tok -match '^-Count$|^-n$') {
            if ($i + 1 -lt $argsList.Count) { $invokeParams.Count = [int]$argsList[++$i] }
            continue
        }
        if ($tok -match '^-Contains$') {
            if ($i + 1 -lt $argsList.Count) { $invokeParams.Contains = [string]$argsList[++$i] }
            continue
        }
        if ($tok -match '^-OutFile$') {
            if ($i + 1 -lt $argsList.Count) { $invokeParams.OutFile = [string]$argsList[++$i] }
            continue
        }
        if ($tok -match '^-Type$') {
            if ($i + 1 -lt $argsList.Count) { $invokeParams.Type = [string]$argsList[++$i] }
            continue
        }
        if ($tok -match '^-Title$') {
            if ($i + 1 -lt $argsList.Count) { $invokeParams.Title = [string]$argsList[++$i] }
            continue
        }
        if ($tok -match '^-Body$') {
            if ($i + 1 -lt $argsList.Count) { $invokeParams.Body = [string]$argsList[++$i] }
            continue
        }
        if ($tok -match '^-File$') {
            if ($i + 1 -lt $argsList.Count) { $invokeParams.File = [string]$argsList[++$i] }
            continue
        }
        if ($tok -match '^-Id$|^-Ref$|^-r$') {
            if ($i + 1 -lt $argsList.Count) { $invokeParams.Id = [string]$argsList[++$i] }
            continue
        }
        if ($Cmd -eq 'say' -and -not $invokeParams.ContainsKey('Message') -and $tok -notmatch '^-') {
            $invokeParams.Message = $tok
        }
    }
    return $invokeParams
}

if ($MyInvocation.InvocationName -eq '.' -or $MyInvocation.Line -match '^\s*\.\s+') {
    # Dot-sourced: functions available.
} elseif ($Command -and $Command -ne '') {
    $invokeParams = ConvertFrom-HfRestArgs -RestArgs $Rest -Cmd $Command
    hf-bus @invokeParams
} else {
    hf-bus -Command help
}
