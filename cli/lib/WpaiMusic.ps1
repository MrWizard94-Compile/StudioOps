# WPAI Music package checklist — reads Music/**; writes tickets + drafts; RMW only when EmitTicket.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-WpaiImageSize {
    param([Parameter(Mandatory)][string]$Path)
    try {
        Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue
        $img = [System.Drawing.Image]::FromFile($Path)
        try {
            return [pscustomobject]@{ Width = $img.Width; Height = $img.Height }
        } finally {
            $img.Dispose()
        }
    } catch {
        return $null
    }
}

function Test-WpaiMusicPackage {
    param(
        [string]$ReleaseName,
        [string]$MusicRoot,
        [switch]$EmitTicket,
        [string]$RequestedBy = 'bridge'
    )
    if (-not $MusicRoot) { $MusicRoot = [string](Get-WpaiConfigValue -Name 'music_root' -Default 'C:\WPAI\Music') }
    if (-not $ReleaseName) { $ReleaseName = [string](Get-WpaiConfigValue -Name 'music_release_next' -Default 'Weaponized Mind') }

    $releaseDir = Join-Path $MusicRoot (Join-Path 'Releases' $ReleaseName)
    $trackDir = Join-Path $MusicRoot (Join-Path 'Tracks' $ReleaseName)
    $checks = @()
    $pass = $true

    function New-Check {
        param([string]$Id, [bool]$Ok, [string]$Detail)
        return [pscustomobject]@{ id = $Id; ok = $Ok; detail = $Detail }
    }

    if (-not (Test-Path -LiteralPath $releaseDir)) {
        $checks += New-Check 'release_dir_exists' $false ("Release folder missing: $releaseDir")
        $pass = $false
        $reportPath = Write-WpaiMusicReport -ReleaseName $ReleaseName -ReleaseDir $releaseDir -TrackDir $trackDir -Pass:$false -Checks $checks
        return [pscustomobject]@{
            release_name = $ReleaseName; release_dir = $releaseDir; pass = $false
            checks = $checks; ticket_path = $null; report_path = $reportPath; explicit = $false
        }
    }
    $checks += New-Check 'release_dir_exists' $true ("Release folder: $releaseDir")

    $wavs = @(Get-ChildItem -LiteralPath $releaseDir -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -match '\.wav$' })
    $wavOk = $wavs.Count -ge 1
    if (-not $wavOk) { $pass = $false }
    $checks += New-Check 'final_wav' $wavOk $(if ($wavOk) { ($wavs | ForEach-Object Name) -join ', ' } else { 'No WAV master' })

    $covers = @(Get-ChildItem -LiteralPath $releaseDir -File -ErrorAction SilentlyContinue | Where-Object {
            $_.Extension -match '\.(jpg|jpeg|png)$' -and ($_.Name -match '3000|cover|Cover')
        })
    if ($covers.Count -eq 0) {
        $covers = @(Get-ChildItem -LiteralPath $releaseDir -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -match '\.(jpg|jpeg|png)$' })
    }
    $coverOk = $false
    $coverDetail = 'No cover image found'
    foreach ($c in $covers) {
        $sz = Get-WpaiImageSize -Path $c.FullName
        if ($null -ne $sz -and $sz.Width -ge 3000 -and $sz.Height -ge 3000 -and $sz.Width -eq $sz.Height) {
            $coverOk = $true
            $coverDetail = "{0} ({1}x{2})" -f $c.Name, $sz.Width, $sz.Height
            break
        }
        if ($null -ne $sz) {
            $coverDetail = "{0} is {1}x{2} (need square >=3000)" -f $c.Name, $sz.Width, $sz.Height
        } elseif ($c.Name -match '3000' -and $c.Length -gt 100000) {
            $coverOk = $true
            $coverDetail = "{0} (filename indicates 3000; size {1})" -f $c.Name, $c.Length
            break
        }
    }
    if (-not $coverOk) { $pass = $false }
    $checks += New-Check 'cover_3000' $coverOk $coverDetail

    $metaPath = Join-Path $releaseDir 'meta.txt'
    $metaOk = Test-Path -LiteralPath $metaPath
    $metaDetail = if ($metaOk) { 'meta.txt present' } else { 'meta.txt missing' }
    $metaText = ''
    if ($metaOk) {
        $metaText = Get-Content -LiteralPath $metaPath -Raw -Encoding utf8
        $hasTitle = $metaText -match '(?im)^\s*TITLE\s*:'
        $hasArtist = $metaText -match '(?im)^\s*ARTIST\s*:'
        $hasDisclosure = $metaText -match '(?i)AI disclosure|DDEX|AI-generated'
        $hasHuman = $metaText -match '(?i)Human contributions|LYRICS\s*:|VOCALS\s*:'
        if (-not ($hasTitle -and $hasArtist)) {
            $metaOk = $false; $metaDetail = 'meta.txt missing TITLE/ARTIST'
        } elseif (-not $hasDisclosure) {
            $metaOk = $false; $metaDetail = 'meta.txt missing AI disclosure'
        } elseif (-not $hasHuman) {
            $metaOk = $false; $metaDetail = 'meta.txt missing human contributions'
        } else {
            $metaDetail = 'meta.txt complete (title/artist/disclosure/human)'
        }
    }
    if (-not $metaOk) { $pass = $false }
    $checks += New-Check 'meta_txt' $metaOk $metaDetail

    $lyricsPath = Join-Path $releaseDir 'lyrics.txt'
    $lyricsOk = (Test-Path -LiteralPath $lyricsPath) -and ((Get-Item -LiteralPath $lyricsPath).Length -gt 20)
    if (-not $lyricsOk) { $pass = $false }
    $checks += New-Check 'lyrics_txt' $lyricsOk $(if ($lyricsOk) { 'lyrics.txt present' } else { 'lyrics.txt missing/empty' })

    $explicit = $metaText -match '(?i)EXPLICIT'
    $checks += New-Check 'explicit_flag_noted' $true $(if ($explicit) { 'Explicit — mark at DistroKid' } else { 'No Explicit flag (ok if clean)' })

    $frozenOk = $wavOk -and $coverOk -and $metaOk -and $lyricsOk
    if (-not $frozenOk) { $pass = $false }
    $checks += New-Check 'package_frozen' $frozenOk $(if ($frozenOk) { 'Core freeze set present' } else { 'Package incomplete' })

    $reportPath = Write-WpaiMusicReport -ReleaseName $ReleaseName -ReleaseDir $releaseDir -TrackDir $trackDir -Pass:$pass -Checks $checks

    $ticketPath = $null
    if ($EmitTicket -and $pass) {
        $paths = @($releaseDir) + @($wavs | ForEach-Object FullName) + @($covers | ForEach-Object FullName) + @($metaPath, $lyricsPath)
        $created = New-WpaiApprovalTicket -Kind 'music_publish' `
            -Summary ("Package-ready: {0} — DistroKid human upload only" -f $ReleaseName) `
            -Division 'music' -RequestedBy $RequestedBy -Paths $paths -Payload @{
            release_name  = $ReleaseName
            report_path   = $reportPath
            explicit      = [bool]$explicit
            artist        = 'WPAI'
            ai_disclosure = 'AI-generated material portions (human-AI collaboration)'
        }
        $ticketPath = $created.Path
        try {
            Register-WpaiPendingApproval -TicketId $created.Ticket.id
            Invoke-WpaiBlackboardRmw -Mutator {
                param($bb)
                if ($bb['pipelines'] -is [System.Collections.IDictionary]) {
                    $mr = $bb['pipelines']['music_release']
                    if ($mr -is [System.Collections.IDictionary]) {
                        $mr['next'] = $ReleaseName
                        $mr['checklist_pass'] = $true
                    }
                }
                Add-WpaiEvent -Blackboard $bb -Kind 'pipeline' -StepKey 'music.package_checklist.auto' -Division 'music' -Actor $RequestedBy -Refs @{
                    path = $reportPath; approval_id = $created.Ticket.id
                }
            } | Out-Null
        } catch { }
    } else {
        try {
            Invoke-WpaiBlackboardRmw -Mutator {
                param($bb)
                if ($bb['pipelines'] -is [System.Collections.IDictionary]) {
                    $mr = $bb['pipelines']['music_release']
                    if ($mr -is [System.Collections.IDictionary]) {
                        $mr['checklist_pass'] = $pass
                        $mr['next'] = $ReleaseName
                    }
                }
                Add-WpaiEvent -Blackboard $bb -Kind 'pipeline' -StepKey 'music.package_checklist.auto' -Division 'music' -Actor $RequestedBy -Refs @{ path = $reportPath }
            } | Out-Null
        } catch { }
    }

    return [pscustomobject]@{
        release_name = $ReleaseName
        release_dir  = $releaseDir
        pass         = $pass
        checks       = $checks
        ticket_path  = $ticketPath
        report_path  = $reportPath
        explicit     = [bool]$explicit
    }
}

function Write-WpaiMusicReport {
    param(
        [string]$ReleaseName,
        [string]$ReleaseDir,
        [string]$TrackDir,
        [switch]$Pass,
        [object[]]$Checks
    )
    $reportDir = Join-Path (Get-WpaiConfigValue -Name 'wpai_dir' -Default 'C:\WPAI\Workspace\.wpai') 'drafts\music'
    if (-not (Test-Path -LiteralPath $reportDir)) {
        New-Item -ItemType Directory -Force -Path $reportDir | Out-Null
    }
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $reportPath = Join-Path $reportDir ("package-check-{0}-{1}.md" -f ($ReleaseName -replace '[^\w\-]', '_'), $stamp)
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("# Music package check: $ReleaseName")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("- **When:** $(Get-Date -Format u)")
    [void]$sb.AppendLine("- **Release dir:** ``$ReleaseDir``")
    [void]$sb.AppendLine("- **Track dir:** ``$TrackDir``")
    [void]$sb.AppendLine("- **PASS:** $Pass")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("| Check | OK | Detail |")
    [void]$sb.AppendLine("|-------|----|--------|")
    foreach ($c in $Checks) {
        [void]$sb.AppendLine(("| ``{0}`` | {1} | {2} |" -f $c.id, $(if ($c.ok) { 'yes' } else { 'NO' }), (($c.detail) -replace '\|', '/')))
    }
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("## Next (HITL only)")
    [void]$sb.AppendLine("1. Director reviews approval ticket if emitted.")
    [void]$sb.AppendLine("2. Human DistroKid upload (AI disclosure + Explicit as needed).")
    [void]$sb.AppendLine("3. Record ISRC in meta.txt after upload.")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("_No DistroKid/Bandcamp/YouTube automation._")
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($reportPath, $sb.ToString(), $utf8)
    return $reportPath
}
