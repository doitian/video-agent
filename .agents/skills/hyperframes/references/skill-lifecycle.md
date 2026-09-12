# Skill installation and freshness

Read this reference when diagnosing unexpected workflow behavior or running HyperFrames setup in CI.

This workspace keeps skills project-locally under `.agents/skills`. The core set (`/hyperframes`, the `hyperframes-*` domain skills, `/media-use`) and every workflow skill are already present. Do not install or refresh them through the HyperFrames CLI — that writes user-level copies for every detected agent.

To refresh the project-local tree, run `./scripts/update-skills.ps1` from the repo root.

## What `init` does

`bunx hyperframes init` scaffolds a project. Offline or rate-limited checks degrade gracefully and do not fail project scaffolding.

The `--skip-skills` CLI flag is temporarily ignored. CI and tests may opt out with `HYPERFRAMES_SKIP_SKILLS=1`.

The CLI may print a one-line stale-skill reminder during `render`, `lint`, or `check`. Ignore that reminder here; this project's skills are the ones under `.agents/skills`. Treat a failed workflow as a visible tool failure; do not continue from a remembered workflow contract.
