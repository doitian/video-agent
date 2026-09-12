#!/usr/bin/env pwsh
# Removes Hyperframes skills copied into user-level agent directories by
# `npx hyperframes skills update` (Claude, Gemini, Codex, and the rest).
# Does not touch this repo's .agents/skills or non-Hyperframes skills.
[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$userHome = [Environment]::GetFolderPath('UserProfile')
$sourceSlug = 'heygen-com/hyperframes'

function Get-HyperframesSkillNames {
    $lockPath = Join-Path $root 'skills-lock.json'
    if (-not (Test-Path -LiteralPath $lockPath)) {
        throw "skills-lock.json not found at $lockPath"
    }
    $lock = Get-Content -LiteralPath $lockPath -Raw | ConvertFrom-Json
    $names = @(
        $lock.skills.PSObject.Properties |
            Where-Object { $_.Value.source -eq $sourceSlug } |
            ForEach-Object { $_.Name }
    )
    if ($names.Count -eq 0) {
        throw "no Hyperframes skills listed in $lockPath"
    }
    return $names
}

function Test-PathUnder {
    param([string]$Path, [string]$Parent)
    $full = [System.IO.Path]::GetFullPath($Path)
    $prefix = [System.IO.Path]::GetFullPath($Parent).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
    return $full.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)
}

function Get-GlobalSkillRoots {
    $configHome = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $userHome '.config' }
    $roots = [System.Collections.Generic.List[string]]::new()
    foreach ($base in @($userHome, $configHome)) {
        if (-not (Test-Path -LiteralPath $base)) { continue }
        Get-ChildItem -LiteralPath $base -Directory -Force -ErrorAction SilentlyContinue |
            ForEach-Object {
                $skills = Join-Path $_.FullName 'skills'
                if (Test-Path -LiteralPath $skills) { $roots.Add($skills) }
            }
    }
    foreach ($override in @($env:CODEX_HOME, $env:CLAUDE_CONFIG_DIR, $env:VIBE_HOME, $env:HERMES_HOME, $env:AUTOHAND_HOME)) {
        if (-not $override) { continue }
        $skills = Join-Path $override 'skills'
        if (Test-Path -LiteralPath $skills) { $roots.Add($skills) }
    }

    $nested = @(
        '.gemini\antigravity\skills'
        '.gemini\antigravity-cli\skills'
        '.astrbot\data\skills'
        '.deepagents\agent\skills'
        '.snowflake\cortex\skills'
        '.codeium\windsurf\skills'
        '.pi\agent\skills'
        '.tabnine\agent\skills'
        '.aider-desk\skills'
    )
    foreach ($rel in $nested) {
        $skills = Join-Path $userHome $rel
        if (Test-Path -LiteralPath $skills) { $roots.Add($skills) }
    }

    $unique = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($dir in $roots) {
        $full = [System.IO.Path]::GetFullPath($dir)
        if (Test-PathUnder -Path $full -Parent $root) { continue }
        [void]$unique.Add($full)
    }
    return @($unique)
}

function Get-GlobalSkillLockPath {
    if ($env:XDG_STATE_HOME) {
        return Join-Path $env:XDG_STATE_HOME 'skills\.skill-lock.json'
    }
    return Join-Path $userHome '.agents\.skill-lock.json'
}

function Resolve-ExistingPath {
    param([string]$Path)
    $item = Get-Item -LiteralPath $Path -Force
    $target = $item.Target
    if (-not $target) { return $item.FullName }
    if ($target -is [array]) { $target = $target[0] }
    if (-not [IO.Path]::IsPathRooted($target)) {
        $target = Join-Path $item.Directory.FullName $target
    }
    return [System.IO.Path]::GetFullPath($target)
}

function ConvertTo-RepoSlug {
    param([string]$Value)
    if (-not $Value) { return '' }
    return ($Value -replace '^git\+', '' -replace '^https?://github\.com/', '' -replace '\.git$', '').ToLowerInvariant()
}

function Test-AttributedToHyperframes {
    param($Entry)
    if (-not $Entry) { return $false }
    $source = if ($Entry -is [System.Collections.IDictionary]) { [string]$Entry['source'] } else { [string]$Entry.source }
    $sourceUrl = if ($Entry -is [System.Collections.IDictionary]) { [string]$Entry['sourceUrl'] } else { [string]$Entry.sourceUrl }
    return (ConvertTo-RepoSlug $source) -eq $sourceSlug -or (ConvertTo-RepoSlug $sourceUrl) -eq $sourceSlug
}

$skillNames = Get-HyperframesSkillNames
$removed = [System.Collections.Generic.List[string]]::new()

foreach ($skillsDir in Get-GlobalSkillRoots) {
    foreach ($name in $skillNames) {
        $skillDir = Join-Path $skillsDir $name
        $marker = Join-Path $skillDir 'SKILL.md'
        if (-not (Test-Path -LiteralPath $marker)) { continue }
        if ($PSCmdlet.ShouldProcess($skillDir, 'Remove global Hyperframes skill')) {
            Remove-Item -LiteralPath $skillDir -Recurse -Force
            $removed.Add($skillDir)
            Write-Host "Removed $skillDir"
        }
    }
}

$lockPath = Get-GlobalSkillLockPath
if (Test-Path -LiteralPath $lockPath) {
    $lockPath = Resolve-ExistingPath $lockPath
    $lock = Get-Content -LiteralPath $lockPath -Raw | ConvertFrom-Json -AsHashtable
    $skills = $lock['skills']
    if ($skills -is [System.Collections.IDictionary]) {
        $pruned = [System.Collections.Generic.List[string]]::new()
        foreach ($name in @($skills.Keys)) {
            if ($skillNames -contains $name -or (Test-AttributedToHyperframes $skills[$name])) {
                $pruned.Add([string]$name)
            }
        }
        if ($pruned.Count -gt 0 -and $PSCmdlet.ShouldProcess($lockPath, "Prune $($pruned.Count) Hyperframes lock entr$(if ($pruned.Count -eq 1) { 'y' } else { 'ies' })")) {
            foreach ($name in $pruned) { [void]$skills.Remove($name) }
            $json = ($lock | ConvertTo-Json -Depth 20) -replace "`r`n", "`n"
            if (-not $json.EndsWith("`n")) { $json += "`n" }
            [System.IO.File]::WriteAllText($lockPath, $json)
            Write-Host "Pruned $($pruned.Count) Hyperframes $(if ($pruned.Count -eq 1) { 'entry' } else { 'entries' }) from $lockPath"
        }
    }
}

if ($WhatIfPreference) {
    return
}
if ($removed.Count -eq 0) {
    Write-Host 'No global Hyperframes skills found.'
} else {
    Write-Host "Removed $($removed.Count) global Hyperframes skill $(if ($removed.Count -eq 1) { 'directory' } else { 'directories' })."
}
