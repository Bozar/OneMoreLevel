# One More Level

## About This Game

One More Level is a turn-based Roguelike game made with [Godot engine](https://godotengine.org). It is available on [GitHub](https://github.com/Bozar/OneMoreLevel/releases). The GUI font, [Fira Code](https://github.com/tonsky/FiraCode), is created by Nikita Prokopov. The tileset, [curses_vector](http://www.bay12forums.com/smf/index.php?topic=161328.0), is created by DragonDePlatino for Dwarf Fortress.

Every time you start the game, One More Level presents you with a theme dungeon of unique mechanics and goals. This idea comes from [HyperRogue](https://store.steampowered.com/app/342610/HyperRogue/), one of the most bizarre and fascinating games I have ever played. You can beat the game in five minutes, so it never hurts to go down just one level deeper.

## Key Bindings

Godot engine natively supports keyboards and gamepads (Xbox, DualShock and Nintendo). Xbox buttons are shown in square brackets below.

* Move: Arrow keys, Vi keys, ASDW, [Direction pad].
* Wait: Space, Z, Period (.), [A].
* Help: Esc, Slash (/), [B].
* Reload after defeat: Space, [A].
* Force reload: O, [Y].
* Quit: Ctrl + W, [Select].

Following keys are available only in help screen.

* Move down: Down, J, S, [Direction pad down].
* Move up: Up, K, W, [Direction pad up].
* Page down: PgDn, Space, F, N.
* Page up: PgUp, B, P.
* Scroll to top: Home, G.
* Scroll to bottom: End, Shift + G.
* Exit help: Esc, Slash (/), [B].
* Switch text: Enter, [A].
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

* Set `wizard_mode` to `true` to enable wizard keys.
* `rng_seed` accepts a positive integer as random number generator seed.
* Feed `world_tag` with a string in `data/world_list.md` to specify the dungeon type.
* Add world names from `data/world_list.md` to `exclude_world` to filter out these worlds from rotation.
