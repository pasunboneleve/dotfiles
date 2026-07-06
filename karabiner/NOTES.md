# Karabiner-Elements config — design notes

Exhaustive documentation for `karabiner.json`. **It lives here because `karabiner.json`
is strict JSON and Karabiner-Elements rewrites the file on every change, stripping anything
that isn't part of the spec — so literal `//` comments cannot survive there.** The only
durable in-file documentation is the per-rule `"description"` field (which the app preserves
and shows in its UI); everything else lives in this file. Keep this file in sync when you
change a rule.

There is exactly one profile: **`moonlander home-row`** (`selected: true`).

---

## 0. Deployment (how this file reaches `~/.config/karabiner`)

Managed by chezmoi from `~/src/projects/chezmoi-config`, **Design B**:

- `~/.config/karabiner/` is a **real directory** (so Karabiner's own churn — `assets/`,
  `automatic_backups/` — stays *local* and out of the `dotfiles` git repo).
- Only `~/.config/karabiner/karabiner.json` is a **symlink** → `../dotfiles/karabiner/karabiner.json`,
  i.e. into this repo (the `.config/dotfiles` chezmoi git-repo external).
- chezmoi source: `dot_config/karabiner/symlink_karabiner.json` (content `../dotfiles/karabiner/karabiner.json`).

> History: before 2026-06-24 the whole `~/.config/karabiner` directory was symlinked into
> this repo, which made chezmoi fight the app every `apply` (it wanted a directory, found a
> symlink) and littered `~/.config/karabiner.pre-dotfiles-link.*` / `.raced` backups. Design B
> fixed that. Do **not** force-refresh externals (`-R=always`) on routine applies — it makes
> chezmoi re-pull this repo and clash with whatever Karabiner just wrote. Commit & push your
> tuning to the `dotfiles` repo instead; let the 168h `refreshPeriod` pull updates.

### Editing safely
- Edit via the Karabiner-Elements UI **or** by hand here. Either way, **commit the result to
  the `dotfiles` repo** so it isn't lost when externals refresh.
- After hand-editing JSON, Karabiner validates on load; a syntax error makes it ignore the file
  and fall back to defaults. Validate before relying on it.

---

## 1. Device gating — Moonlander vs everything else

Every rule is scoped by device, using ZSA Moonlander identifiers **`vendor_id: 12951`,
`product_id: 6505`**:

- `device_if` { 12951/6505 }  → applies **only on the Moonlander**.
- `device_unless` { 12951/6505 } → applies on **every other keyboard** (built-in MacBook, etc.).

Home-row mods are defined **twice** — once `device_if` Moonlander (rule §4) and once
`device_unless` (rule §11) — with identical behaviour, so the same muscle memory works on every
keyboard. They are kept as two rules so the Moonlander variant can diverge later if needed.

## 2. Global timing parameters

`complex_modifications.parameters`:

- `basic.to_if_alone_timeout_milliseconds: 150` — a tapped dual-role key counts as "alone" only
  if released within 150 ms.
- `basic.to_if_held_down_threshold_milliseconds: 40` — default hold threshold (overridden to
  300 ms on the Mission-Control keys, and 1000 ms for the Command-alone taps).

---

## 3. Mission Control on the thumb / Command keys

**On the Moonlander** (§ rules 1–2): the thumb-cluster `left_command` / `right_command`
- tap → `Cmd` (normal),
- **hold alone ≥ 300 ms → Mission Control** (`apple_vendor_keyboard_key_code: mission_control`),
- hold + another key → behaves as `Cmd` (it's `to: left_command`).

**On other keyboards** (§ rules 4–5): plain `left_command` / `right_command`
- tapped **alone** (within 1000 ms) → **Mission Control**,
- pressed **with any other key → nothing** (`vk_none`). This deliberately disables the system
  `Cmd` on non-Moonlander boards in this profile; Cmd comes from the home-row `a`/`;` instead.

### Right-Command gesture guard (§ rule 5)
While `right_command` is held on a non-Moonlander board it sets the variable
`right_command_pending = 1` (cleared on key-up). Rule §6 ("Space does nothing while Right
Command is pending") swallows `spacebar` during that window, so the Mission-Control gesture
isn't polluted by an accidental space. (Variable: `right_command_pending`.)

---

## 4. Home-row mods (rules §3 Moonlander / §12 others)

Hold a home-row key = a modifier; tap it = the letter (`to_if_alone`). Mods other than Cmd are
`lazy: true` (they only fire if another key is pressed while held, reducing misfires).

| Key | Hold → modifier | Tap → |
|-----|-----------------|-------|
| `a` | **left Command** | `a` |
| `s` | left Shift (lazy) | `s` |
| `d` | left Option/Alt (lazy) | `d` |
| `f` | left Control (lazy) | `f` |
| `j` | right Control (lazy) | `j` |
| `k` | right Option/Alt (lazy) | `k` |
| `l` | right Shift (lazy) | `l` |
| `;` | **left Command** | `;` |

So: **a / ; = Cmd, s / l = Shift, d / k = Alt, f / j = Ctrl.**
`a` and `;` additionally → **Mission Control** if held alone ≥ 300 ms.
**Spotlight = hold `a` (= Cmd) + Space** (Cmd-Space).

---

## 5. Emacs layer

Gives Emacs-style keys *system-wide*, but **only where they wouldn't collide**. Two exclusions
recur via `frontmost_application_unless`:

- **Emacs** (`^org\.gnu\.Emacs`) — it has the real bindings.
- **Terminals** — Ghostty, Terminal.app, iTerm2, Alacritty, Kitty — they pass Ctrl through to
  the shell/TUI.

(The copy rule §10 additionally excludes browsers.)

### 5a. `C-x` prefix state machine (rules §7 enter, §8 subcommands)
Outside Emacs/terminals, **`Ctrl-x`** sets the variable **`ctrl_x_mode = 1`** for **1000 ms**
(a `to_delayed_action` resets it to 0 on timeout/cancel). While `ctrl_x_mode = 1`, the next key
is an Emacs `C-x` chord and resets the mode:

| After `C-x` | Sends | Meaning |
|-------------|-------|---------|
| `h` | Cmd-A | select all |
| `C-f` | Cmd-O | open |
| `C-s` | Cmd-S | save |
| `k` | Cmd-W | close window/tab |
| `C-c` | Cmd-Q | quit app |
| `u` | Cmd-Z | undo |
| `C-g` | Escape | cancel (works even if mode is stuck) |

> The whole Emacs layer (§9 below) is gated `variable_unless ctrl_x_mode = 1`, so single-key
> Emacs bindings are suspended while a `C-x` chord is in flight.

### 5b. Single-key Emacs bindings (rule §9; suspended during `C-x` mode)

| Chord | Sends | Meaning |
|-------|-------|---------|
| `C-b` / `C-f` | ←  / → | char left / right |
| `C-p` / `C-n` | ↑ / ↓ | line up / down |
| `M-b` / `M-f` | Opt-← / Opt-→ | word left / right |
| `C-a` | Cmd-← | line start |
| `C-e` | native app handling | line end |
| `M-v` / `C-v` | PageUp / PageDown | scroll |
| `M-<` (Opt-Shift-,) / `M->` (Opt-Shift-.) | Cmd-↑ / Cmd-↓ | buffer start / end |
| `C-m` / `C-j` | Return | newline |
| `C-o` | Return, ← | open line |
| `C-w` / `C-y` | Cmd-X / Cmd-V | cut (kill region) / paste (yank) |
| `C-d` / `M-d` | Fwd-Delete / Opt-Fwd-Delete | delete char / word |
| `C-k` | Shift-Cmd-→, Cmd-X | kill to end of line |
| `C-Opt-Space` | Opt-Shift-→ | set/extend selection by word |
| `C-/` | Cmd-Z | undo |
| `C-s` / `C-r` | Cmd-F / Shift-F3 | find / find previous |
| `M-%` (Opt-Shift-5) | Cmd-Opt-F | find & replace |
| `C-g` | Escape | cancel |

### 5c. Copy (rule §10)
`M-w` → **Cmd-C** — additionally excluded in browsers (Chrome, Chromium, Safari, Firefox, Brave)
because `Opt-w` there can clash with site shortcuts.

---

## 6. Ghostty quality-of-life
Ghostty copies selected text on selection, and middle-click pastes the
selection.

---

## 7. Rule index (order in `karabiner.json`)
1. Moonlander Left GUI → Cmd / hold = Mission Control
2. Moonlander Right GUI → Cmd / hold = Mission Control
3. Moonlander home-row mods (+ Spotlight on hold-a + Space)
4. (other keyboards) Left Command alone → Mission Control; +key → nothing
5. (other keyboards) Right Command alone → Mission Control; sets `right_command_pending`
6. Space suppressed while `right_command_pending`
7. Emacs `C-x` prefix → set `ctrl_x_mode`
8. Emacs `C-x` subcommands
9. Emacs single-key bindings (navigation/editing/clipboard/search)
10. Emacs `M-w` copy → Cmd-C (also excl. browsers)
11. Home-row mods on non-Moonlander keyboards

(Variables used: `ctrl_x_mode`, `right_command_pending`.)
