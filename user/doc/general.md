# General Help

## About This Game

(Press Enter to view dungeon help.)

One More Level is a turn-based Roguelike game made with Godot engine. The GUI font, Fira Code, is created by Nikita Prokopov. The tileset, curses_vector, is created by DragonDePlatino for Dwarf Fortress.

Every time you start the game, One More Level presents you with a theme dungeon of unique mechanics and goals. This idea comes from HyperRogue, one of the most bizarre and fascinating games I have ever played. You can beat the game in five minutes, so it never hurts to go down just one level deeper.

## Game Mechanics

There is a count down timer at the top right corner of the main screen. You have 24 turns at most. When it reduces to zero, you lose the game. Sometimes enemies and environment are able to consume your remaining turns. They might also kill you in other ways. On the other hand, every theme dungeon has a unique winning condition.

Press `Help` key to read these mechanics. The help text is also available in `doc/`.

## Change Game Settings

Edit `data/setting.json` for play testing.

* Set `wizard_mode` to `true` to enable wizard keys.
* `rng_seed` accepts a positive integer as random number generator seed.
* Feed `world_tag` with a string in `data/world_list.md` to specify the dungeon type.
* Add world names from `data/world_list.md` to `exclude_world` to filter out these worlds from rotation.
