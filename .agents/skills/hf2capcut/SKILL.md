---
name: hf2capcut
description: Convert an existing Hyperframes HTML composition into an editable CapCut or 剪映专业版 (JianYing) draft using hf2capcut through bunx. Use for project or timeline handoff to those editors, rather than rendered video export.
---

# Hyperframes to CapCut / 剪映专业版

Use `bunx github:vasanthsreeram/hf2capcut` for the converter. Keep all invocation examples and executed commands on `bunx`.

## Convert

Inspect the existing composition's entry HTML, canvas dimensions, frame rate, timed elements, and media paths. The converter reads `data-start`, `data-duration`, and `data-track-index`; it does not render the browser or evaluate animation code.

Choose `--capcut lv` for 剪映 / JianYing and `--capcut cc` for CapCut International. In this repository, use JianYing when the user leaves the target unspecified. Pass the composition's frame rate explicitly because the converter otherwise defaults to 30 fps. Use a fresh output folder under `output/` unless the user specifies another destination.

```powershell
bunx github:vasanthsreeram/hf2capcut convert ./index.html -o ./output/jianying --capcut lv --fps 30
```

Replace paths and frame rate with the actual project values. Optional `--name "Project name"` sets the draft name; `--canvas 1080x1920` overrides its canvas. When checking available options, use:

```powershell
bunx github:vasanthsreeram/hf2capcut convert --help
```

## Check and hand off

- Confirm the command succeeds and both `draft_content.json` and `draft_meta_info.json` parse as JSON. Compare the canvas, duration, tracks, and representative segment times with the input; draft timing is in microseconds.
- The converter writes media references as supplied and creates an empty `Resources/` folder. Resolve local relative paths against the source HTML, copy required media while preserving distinct filenames, and verify references resolve from the destination. Merely copying files does not rewrite draft paths; relink in the editor when necessary. Report unresolved or remote media instead of claiming a self-contained project.
- For installation into the editor, close it first and copy the whole generated folder into a new, uniquely named draft directory. Preserve existing drafts. Use a custom drafts location if the user has configured one; otherwise the upstream Windows defaults are:
  - JianYing: `$env:LOCALAPPDATA\JianyingPro\User Data\Projects\com.lveditor.draft\`
  - CapCut: `$env:LOCALAPPDATA\CapCut\User Data\Projects\com.lveditor.draft\`
- Exporting a folder alone does not require changing the editor's live drafts. If the task includes importing it, complete that handoff within the authorized scope.
- Report the output path, target editor, unresolved assets, and conversion losses. Claim editor compatibility only after opening the draft successfully in that installed version; JSON validation alone establishes only that conversion produced parseable output.

## Fidelity limits

This third-party converter transfers a timeline structure, not the complete rendered appearance. It maps timed video, images, audio, and basic text to tracks and clips. GSAP animations and easing are dropped; CSS effects and flex/grid layout are not translated. Fonts may need reselection, text may need repositioning, and nested rich-text styling is flattened.

If visual fidelity matters, explain which elements need recreation or propose rendering those elements as media for the handoff. Do not silently replace the requested editable draft with a flattened movie.

Upstream usage, mapping, and limitations: [hf2capcut README](https://github.com/vasanthsreeram/hf2capcut#readme).
