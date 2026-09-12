#!/usr/bin/env pwsh
# Updates the skills bundled in .agents/skills.
#
# Hyperframes is managed by the `skills` CLI and tracked in skills-lock.json.
# ffmpeg-skill ships its own installer, so it is excluded from `bunx skills`
# and refreshed with `bunx ffmpeg-skill` into the project-local skill directory.
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Push-Location $root
try {
    Write-Host 'Updating hyperframes (bunx skills)...'
    bunx skills add heygen-com/hyperframes --skill '*' -a codex --copy -y
    if ($LASTEXITCODE -ne 0) { throw "bunx skills failed with exit code $LASTEXITCODE" }

    Write-Host 'Updating ffmpeg-skill (bunx ffmpeg-skill)...'
    bunx ffmpeg-skill --dir .agents/skills
    if ($LASTEXITCODE -ne 0) { throw "bunx ffmpeg-skill failed with exit code $LASTEXITCODE" }
}
finally {
    Pop-Location
}
