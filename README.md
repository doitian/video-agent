# video-agent

A workspace for an AI agent to cut and edit videos from natural-language instructions.

## Skills

- [Hyperframes](https://github.com/heygen-com/hyperframes): HTML-based video compositions, animation, and rendering. The entry-point skill installs additional workflows as needed.
- [FFmpeg skill](https://github.com/kajisho5/ffmpeg-skill): local cutting, joining, reframing, audio editing, and export verification.

Both are installed in `.agents/skills/` for Codex. `skills-lock.json` records their sources and content hashes.

## Setup

Install Bun, Python 3.9+, and FFmpeg (including `ffprobe`), then open this repository in Codex. The bundled skills are available on the next turn.

To reinstall or update the skills:

```powershell
bunx skills add heygen-com/hyperframes --full-depth --skill hyperframes --agent codex --yes
bunx skills add kajisho5/ffmpeg-skill --skill ffmpeg-skill --agent codex --yes
```

Check local editing capabilities:

```powershell
python .agents/skills/ffmpeg-skill/scripts/_contract.py doctor --json
```

Check each tool's `usable` result. On Windows, the default-font `drawtext` check may fail; text graphics can require an explicit font file.

Keep footage in `media/` and renders in `output/` (both ignored by Git). For example:

> Cut media/interview.mp4 to keep 00:45-03:10 and 05:00-06:30, join the segments, and save output/interview-cut.mp4. Preserve the original and verify the result.

## License

Project-owned files are licensed under the [Mozilla Public License 2.0](LICENSE). Bundled third-party skills retain their upstream licenses: Hyperframes is Apache-2.0 (see `third-party/hyperframes-LICENSE`), and FFmpeg skill is MIT (see `.agents/skills/ffmpeg-skill/LICENSE`).
