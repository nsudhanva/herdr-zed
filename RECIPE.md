# Herdr Zed

The Herdr `main` layout with one more button in the tab bar: **Zed**,
next to **Files** and **Changes**. A click opens the active space's
repository in Zed on this computer. A space on an SSH machine opens as
a Zed remote project.

![Herdr Zed](preview.png)

## What you see

- The window is the shipped `main` layout, unchanged.
- The tab bar ends with **+**, **Files**, **Changes**, then **Zed**.
- The Zed button has the same look as the panel buttons: 26 px tall,
  8 px side padding, 5 px gap, 12 px text, `muted` text on `chrome`,
  `hover` background. Its icon is a 14 px tinted "Z" in a rounded square.
- The Zed button is never shown as selected: it opens no panel.

## How it behaves

- Click **Zed**: the label changes to `Opening…` in `dim` text until the
  Zed CLI returns, then changes back to `Zed`.
- Success: a `success` toast "Opened in Zed" with the target, 3 s.
- Failure: an `error` toast "Could not open in Zed" with the reason.
- A click while opening, or with no active space, does nothing.
- Agent statuses do not change the button.

## Built from

- `layouts/main-zed.json`: a clone of `main` (`layout.clone`). Only the
  tab bar block changes: `content.mod` is `zed-tabs`.
- `mods/zed-tabs`: a clone of `tabs` (`mod.clone`). Adds `zedButton()`
  after the Changes panel button. The click runs `openInZed(space)` in
  `cx.spawn`. The tab bar mod lives as long as the layout, so the task
  is not cancelled.
- `mods/zed-tabs/zed.js`, which uses `exec`, `hc`, `panes` and `notify`
  from `herdr`:
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

- Do not start the launch from a popup that closes itself first: an
  async task in a closed overlay is cancelled. The tab bar is safe.
- `exec` with `cwd` on a remote machine fails if the folder does not
  exist there. Catch it and fall back.
- The SSH target from `hc machine ls` is an `~/.ssh/config` alias. Zed
  runs the system `ssh`, so the alias resolves.
- Clones are never updated by Herdr. Rebuild `zed-tabs` from the new
  shipped `tabs` when Herdr changes it.

## Done when

- `herdr-app check mods/zed-tabs` passes.
- `herdr-app status` shows layout `main-zed` and no errors.
- In a local space, **Zed** opens the repository root in Zed.
- In an SSH space, **Zed** opens `ssh://<host>/<repo root>` in Zed.
