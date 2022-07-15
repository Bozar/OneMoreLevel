# One More Level

## About This Game

One More Level is a turn-based Roguelike game made with [Godot engine](https://godotengine.org). It is available on [GitHub](https://github.com/Bozar/OneMoreLevel/releases). The GUI font, [Fira Code](https://github.com/tonsky/FiraCode), is created by Nikita Prokopov. The tileset, [curses_vector](http://www.bay12forums.com/smf/index.php?topic=161328.0), is created by DragonDePlatino for Dwarf Fortress.

You can play One More Level either locally (which is an executable file) or as a HTML5 game on [itch.io](https://bozar.itch.io/one-more-level). You can change most settings (except `palette`, see below) when playing online.

Every time you start the game, One More Level presents you with a theme dungeon of unique mechanics and goals. This idea comes from [HyperRogue](https://store.steampowered.com/app/342610/HyperRogue/), one of the most bizarre and fascinating games I have ever played. You can beat the game in five minutes, so it never hurts to go down just one level deeper.

## Key Bindings

Godot engine natively supports keyboards and gamepads (Xbox, DualShock and Nintendo). Xbox buttons are shown in square brackets below. If you need mouse support, press `V` to open debug menu, then set `mouse_input` to `true`.

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

These keys are available in wizard mode (see below).

* Add 1 turn: T.
* Fully restore turns: F.

## Game Mechanics

There is a count down timer at the top right corner of the main screen. You have 24 turns at most. When it reduces to zero, you lose the game. Sometimes enemies and environment are able to consume your remaining turns. They might also kill you in other ways. On the other hand, every theme dungeon has a unique winning condition.

Press `C` to read these mechanics. The help text is also available in `doc/`.

## Change Game Settings

Edit `data/setting.json` for play testing. You can also change settings in debug menu by pressing `V`. Debug settings overwrite their counterparts in `data/setting.json`. All settings take effect when starting a new game.

When in debug menu, if a text field requires a boolean value, strings match this pattern are `true`: `^(true|t|yes|y|[1-9]\d*)$`.

Set `rng_seed` to a positive integer as a random number generator seed. When in debug menu, seed digits can be separated by characters: `[-,.\s]`. For example: `12-3,4.56` is the same as `123456`.

Add world names from `data/world_list.md` to `include_world` or `exclude_world` to customize your world rotation list.

Set `wizard_mode` to `true` to enable wizard keys. Set `show_full_map` to `true` to disable fog of war. Set `mouse_input` to `true` to move, wait and reload game by mouse.

Leave `palette` blank to use the default color theme. If you want to use another theme, copy a json file (for example, `blue.json`) from `palette/` to `data/`, and then feed `palette` with a file name with or without the json file extension (both `blue` and `blue.json` works). You can also create your own theme based on `default.json`.

## Status Indicators

In the lower right corner of the main screen, there is a bar under the version number. Three of the right most segments are indicators. A minus sign (-) means `false` and a plus sign (+) means `true`. From left to right, these indicators show that:

* Whether `setting.json` is broken;
* Whether `wizard_mode` is `true`;
* Whether `mouse_input` is `true`.

## Export the Game

If you want to export One More Level using Godot engine by yourself, first you need to download the project from GitHub (see above, About This Game). You also have to tweak export settings to filter certain files. In the GitHub repository, refer to `misc/export.md` for more information.
