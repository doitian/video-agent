# video-agent

A workspace for an AI agent to cut and edit videos from natural-language instructions.

## Skills

- [Hyperframes](https://github.com/heygen-com/hyperframes): HTML-based video compositions, animation, and rendering. All 20 published skills are bundled; the `/hyperframes` router selects the owning workflow and loads the rest on demand.
- [Remotion](https://github.com/remotion-dev/skills): React-based video composition skills. All 12 published skills are bundled; `/remotion-best-practices` routes to the rest.
- [FFmpeg skill](https://github.com/kajisho5/ffmpeg-skill): local cutting, joining, reframing, audio editing, and export verification.
- [hf2capcut](.agents/skills/hf2capcut/SKILL.md): project-local guidance for converting Hyperframes compositions into editable 剪映专业版 or CapCut drafts using `bunx`.

Skills are installed in `.agents/skills/` for Codex only — never in the user-level `~/.agents/skills` or any other agent's global skills directory. `skills-lock.json` records the Hyperframes and Remotion skills managed by `bunx skills`; FFmpeg skill is excluded from `bunx skills` (it ships its own installer), and hf2capcut is maintained in this repository.

## Setup

Install Bun, Python 3.9+, and FFmpeg (including `ffprobe`), then open this repository in Codex. The bundled skills are available on the next turn.

To reinstall or update the skills in this project:

```powershell
./scripts/update-skills.ps1
```

Hyperframes and Remotion are installed and updated through `bunx skills` and tracked in `skills-lock.json`. FFmpeg skill ships its own installer, so it is deliberately excluded from `bunx skills` and refreshed with `bunx ffmpeg-skill --dir .agents/skills` (project-local, never `~/.agents`).

To run the updates by hand:

```powershell
bunx skills add heygen-com/hyperframes --skill '*' -a codex --copy -y
bunx skills add remotion-dev/skills --skill '*' -a codex --copy -y
bunx ffmpeg-skill --dir .agents/skills
```

This installs all 20 published Hyperframes skills and all 12 Remotion skills into `.agents/skills/` as real files (`--copy`, not symlinks). It resolves the skills.sh registry blob, which can lag upstream `main` by hours; the docs' freshness command (`npx hyperframes skills update`) writes user-level skills for every detected agent, so it is not used here.

To delete those global copies (Claude, Gemini, Codex, and other agent skill dirs) without touching this repo:

```powershell
./scripts/cleanup-global-skills.ps1
```

Check local editing capabilities:

```powershell
python .agents/skills/ffmpeg-skill/scripts/_contract.py doctor --json
```

Check each tool's `usable` result. On Windows, the default-font `drawtext` check may fail; text graphics can require an explicit font file.

Keep footage in `media/` and renders in `output/` (both ignored by Git). For example:

> Cut media/interview.mp4 to keep 00:45-03:10 and 05:00-06:30, join the segments, and save output/interview-cut.mp4. Preserve the original and verify the result.

## License

Project-owned files are licensed under the [Mozilla Public License 2.0](LICENSE). Bundled third-party skills retain their upstream licenses: Hyperframes is Apache-2.0 (see `third-party/hyperframes-LICENSE`), and FFmpeg skill is MIT (see `third-party/ffmpeg-skill-LICENSE`).
