# Key Bindings

[INPUT_HINT]

One More Level is made with Godot engine, which natively supports keyboards and gamepads (Xbox, DualShock and Nintendo). Xbox buttons are shown in square brackets below. If you need mouse support, press `V` to open debug menu, then set `mouse_input` to `true`.

General gameplay:

* Move: Arrow keys, Vi keys, ASDW, Left-click, [Direction pad].
* Wait: Space, Enter, Z, Period (.), Right-click, [A].
* Reload after win/lose: Space, Right-click, [A].
* Quit: Ctrl + W, [Select].

Menu keys:

* Open Help menu: C, [B].
* Open Debug menu: V.
* Exit menu: Esc, Ctrl + [, [B].

Function keys:

* Force reload: O, Left-click[!], [Y].
* Replay dungeon: R, [X].
* Replay world: U, [Start].
* Copy RNG seed to clipboard: Ctrl + C.
* Copy world name to clipboard: Ctrl + D.

Force reload and two replay keys start a new game in different ways.

* Force reload: A random seed and world tag.
* Replay dungeon: The same seed and world tag.
* Replay world: A random seed and the same world tag.

[!] In order to force reload by mouse, left-click the grid that is just outside the bottom right corner of the dungeon, or, put it in another way, the grid that is on the left end of the RNG seed.

Following keys are available in Help menu.

* Move down: Down, J, S, [Direction pad down].
* Move up: Up, K, W, [Direction pad up].
* Page down: PgDn, Space, F, N, [RB].
* Page up: PgUp, B, P, [LB].
* Scroll to bottom: End, Shift + G, [RT].
* Scroll to top: Home, G, [LT].
* Switch to next help: Enter, Right, L, D, [A], [Direction pad right].
* Switch to previous help: Left, H, A, [Direction pad left].

Following keys are available in Debug menu. Quote from `Godot Docs` with slight modification.

* Copy: Ctrl + C.
* Cut: Ctrl + X.
* Paste/"yank": Ctrl + V, Ctrl + Y.
* Undo: Ctrl + Z.
* Redo: Ctrl + Shift + Z.
* Delete text from the cursor position to the beginning of the line: Ctrl + U.
* Delete text from the cursor position to the end of the line: Ctrl + K.
* Select all text: Ctrl + A.
* Move the cursor to the beginning/end of the line: Up/Down arrow.

These keys are available in wizard mode (see General Help).

* Add 1 turn: T.
* Fully restore turns: F.
