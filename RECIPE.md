# Herdr Zed

The Herdr `main` layout with one more row in the tab bar's **+** menu:
**Zed**. A click opens the active space's repository in Zed on this
computer. A space on an SSH machine opens as a Zed remote project.

![Herdr Zed](preview.png)

## What you see

- The window is the shipped `main` layout, unchanged.
- The **+** popup (250 px wide, 543 px tall) has a **Zed** row directly
  under **Terminal**: a 14 px tinted "Z" in a rounded square, the label
  `Zed`, and a dim 11 px hint on the right. The hint is `ssh` when the
  active space is on another machine, else empty.
- All other rows (agents, New space, New worktree, Open worktree) are the
  shipped ones.

## How it behaves

- Click **Zed**: the hint changes to `opening…` and the row dims. The
  popup stays open until the Zed CLI returns, then closes.
- Success: a `success` toast "Opened in Zed" with the target, 3 s.
- Failure: an `error` toast "Could not open in Zed" with the reason.
- A second click while opening does nothing.
- Agent statuses are not shown in this row.

## Built from

- `layouts/main-zed.json`: a clone of `main` (`layout.clone`). Only the
  tab bar block changes: `content.mod` is `zed-tabs`.
- `mods/zed-tabs`: a clone of `tabs` (`mod.clone`). The `tab-new` button
  calls `openOverlay({ mod: "zed-new-menu", kind: "popup", width: 250, height: 543 })`.
- `mods/zed-new-menu`: a clone of `new-menu`. Adds `zedRow(space)` and
  raises the content height by 31 px (`Math.min(522, 198 + n * 31)`).
- `mods/zed-new-menu/zed.js`, which uses `exec`, `hc`, `panes` and
  `notify` from `herdr`:
  1. Folder: `git rev-parse --show-toplevel` with `cwd` = the focused
     terminal pane's `cwd` (else the space `folder`), `on` = the space's
     `machine`. Else that `cwd` if absolute. Else `pwd` on that machine.
  2. Local space: the target is the folder.
  3. Remote space: `hc machine ls --json`, match `name`, read `target`.
     The target is `ssh://<target><folder>`. A machine with `via` is
     refused.
  4. Run `zed <target>`, else `/Applications/Zed.app/Contents/MacOS/cli <target>`.
- Programs run: `git`, `pwd` (on the space's machine), `hc`, `zed`
  (on this computer). No network access of its own.

## Watch out

- The shipped `row()` closes the popup before it runs the action. An
  async task started from a closed overlay is cancelled, so the Zed row
  has its own click handler and closes the popup after the launch.
- `exec` with `cwd` on a remote machine fails if the folder does not
  exist there. Catch it and fall back.
- The SSH target from `hc machine ls` is an `~/.ssh/config` alias. Zed
  runs the system `ssh`, so the alias resolves.
- Clones are never updated by Herdr. Rebuild them from new shipped
  versions when Herdr changes `tabs` or `new-menu`.

## Done when

- `herdr-app check mods/zed-tabs` and `herdr-app check mods/zed-new-menu` pass.
- `herdr-app status` shows layout `main-zed` and no errors.
- In a local space, **+ → Zed** opens the repository root in Zed.
- In an SSH space, **+ → Zed** opens `ssh://<host>/<repo root>` in Zed.
