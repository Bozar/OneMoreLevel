# One More Level

## About This Game

One More Level is a turn-based Roguelike game made with [Godot engine](https://godotengine.org). It is available on [GitHub](https://github.com/Bozar/OneMoreLevel/releases). The GUI font, [Fira Code](https://github.com/tonsky/FiraCode), is created by Nikita Prokopov. The tileset, [curses_vector](http://www.bay12forums.com/smf/index.php?topic=161328.0), is created by DragonDePlatino for Dwarf Fortress.

You can play One More Level either locally (which is an executable file) or as a HTML5 game on [itch.io](https://bozar.itch.io/one-more-level). However, you cannot change settings (more details below) when playing online.

Every time you start the game, One More Level presents you with a theme dungeon of unique mechanics and goals. This idea comes from [HyperRogue](https://store.steampowered.com/app/342610/HyperRogue/), one of the most bizarre and fascinating games I have ever played. You can beat the game in five minutes, so it never hurts to go down just one level deeper.

## Key Bindings

Godot engine natively supports keyboards and gamepads (Xbox, DualShock and Nintendo). Xbox buttons are shown in square brackets below.

General gameplay:

* Move: Arrow keys, Vi keys, ASDW, [Direction pad].
* Wait: Space, Enter, Z, Period (.), [A].
* Help: Esc, Slash (/), [B].
* Reload after defeat: Space, [A].
* Quit: Ctrl + W, [Select].

Function keys:

* Force reload: O, [Y].
* Replay dungeon: R, [X].
* Replay world: U, [Start].
* Copy RNG seed to clipboard: Ctrl + C, Ctrl + Y.

Force reload and two replay keys start a new game in different ways.

* Force reload: A random seed and world tag.
* Replay dungeon: The same seed and world tag.
* Replay world: A random seed and the same world tag.

Following keys are available only in help screen.

* Move down: Down, J, S, [Direction pad down].
* Move up: Up, K, W, [Direction pad up].
* Page down: PgDn, Space, F, N, [RB].
* Page up: PgUp, B, P, [LB].
* Scroll to bottom: End, Shift + G, [RT].
* Scroll to top: Home, G, [LT].
* Exit help: Esc, Slash (/), [B].
* Switch to next help: Enter, Right, L, D, [A], [Direction pad right].
* Switch to previous help: Left, H, A, [Direction pad left].

These keys are available in wizard mode (see below).

* Add 1 turn: T.
* Fully restore turns: F.

## Game Mechanics

There is a count down timer at the top right corner of the main screen. You have 24 turns at most. When it reduces to zero, you lose the game. Sometimes enemies and environment are able to consume your remaining turns. They might also kill you in other ways. On the other hand, every theme dungeon has a unique winning condition.

Press `Help` key to read these mechanics. The help text is also available in `doc/`.

## Change Game Settings

Edit `data/setting.json` for play testing.

Set `wizard_mode` to `true` to enable wizard keys. When in wizard mode, there is a plus sign (+) on the left side of version number. If you see a question mark (?) instead, it means your `setting.json` is broken.

Set `rng_seed` to a positive integer as a random number generator seed.

Add world names from `data/world_list.md` to `include_world` or `exclude_world` to customize your world rotation list.

Set `show_full_map` to `true` to disable fog of war.

Leave `palette` blank to use the default color theme. If you want to use another theme, copy a json file (for example, `blue.json`) from `palette/` to `data/`, and then feed `palette` with a file name with or without the json file extension (both `blue` and `blue.json` works). You can also create your own theme based on `default.json`.
