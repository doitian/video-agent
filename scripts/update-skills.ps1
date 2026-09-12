#!/usr/bin/env pwsh
# Updates the skills bundled in .agents/skills.
#
# Hyperframes is managed by the `skills` CLI and tracked in skills-lock.json.
# ffmpeg-skill ships its own installer, so it is excluded from `bunx skills`
# and refreshed with `bunx ffmpeg-skill` into the project-local skill directory.
# After those installs, opencode (default model) rewrites the bundled files:
# scrub global `hyperframes skills update`, and prefer `bunx` over `npx`.
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

    Write-Host 'Patching bundled skills (opencode, default model)...'
    $patchPrompt = @'
Edit only files under .agents/skills in this repo. Do not commit. Do not edit README, scripts, or anything outside .agents/skills.

This workspace installs skills project-locally with `bunx skills` / `bunx ffmpeg-skill`. Never tell an agent to run `npx hyperframes skills update` (or `bunx hyperframes skills update`): that HyperFrames CLI command writes user-level skills for every detected agent.

Do both of the following, in order. Read the current files and rewrite them so they still make sense after future upstream wording changes — do not rely on one brittle regex.

1. Scrub every mention of `npx hyperframes skills update` / `hyperframes skills update` (with or without a skill name).
   - Delete "keep this skill fresh" callouts and any "run this before using the workflow" install fences whose only job is that command.
   - In routing/lifecycle/borrowing docs, remove instructions to install or refresh skills via that CLI. Skills in this project are already present; say so if a sentence still needs a replacement.
   - Keep surrounding prose coherent. Drop empty code fences and leftover "before relying on this workflow, run:" stubs.
   - In executable JS and its tests, do not leave that command as a recovery/fix string. Point recovery at `./scripts/update-skills.ps1` and update assertions to match. Code must stay valid.

2. Replace remaining command usage of `npx` with `bunx` in the same tree: docs, examples, spawn/exec arguments, package.json-style script strings, `npx hyperframes`, `npx skills add`, `npx remotion`, `npx esbuild`, `npx puppeteer`, `npx ffmpeg-skill`, and similar invocations.
   - Do not rename npm internals: `npx-cli.js`, `npx-sync.mjs`, `npx.cmd` in Windows-resolution comments, or identifiers such as `resolveNpxInvocation` / `resolveNpxCliPath`. Those are npm's npx implementation, not commands to run.

Preserve Linux (LF) line endings.

When done, confirm there is no remaining `hyperframes skills update` mention, and that leftover `npx` is only those npm internals.
'@
    & opencode run --auto --title 'Patch bundled skills' $patchPrompt
    if ($LASTEXITCODE -ne 0) { throw "opencode skill patch failed with exit code $LASTEXITCODE" }
}
finally {
    Pop-Location
}
