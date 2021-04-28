# General Help

## About This Game

(Press Enter to view dungeon help.)

One More Level is a turn-based Roguelike game made with Godot engine. It is available on GitHub. The GUI font, Fira Code, is created by Nikita Prokopov. The tileset, curses_vector, is created by DragonDePlatino for Dwarf Fortress.

Every time you start the game, One More Level presents you with a theme dungeon of unique mechanics and goals. This idea comes from HyperRogue, one of the most bizarre and fascinating games I have ever played. You can beat the game in five minutes, so it never hurts to go down just one level deeper.

## Game Mechanics

There is a count down timer at the top right corner of the main screen. You have 24 turns at most. When it reduces to zero, you lose the game. Sometimes enemies and environment are able to consume your remaining turns. They might also kill you in other ways. On the other hand, every theme dungeon has a unique winning condition.

Press `Help` key to read these mechanics. The help text is also available in `doc/`.

## Change Game Settings

Edit `data/setting.json` for play testing.

Set `wizard_mode` to `true` to enable wizard keys. When in wizard mode, there is a plus sign (+) on the left side of version number. If you see a question mark (?) instead, it means your `setting.json` is broken.

Set `rng_seed` to a positive integer as a random number generator seed.

Feed `world_tag` with a string in `data/world_list.md` to specify the dungeon type.

Add world names from `data/world_list.md` to `exclude_world` to filter out these worlds from rotation.

Set `show_full_map` to `true` to disable fog of war.

Leave `palette` blank to use the default color theme. If you want to use another theme, copy a json file (for example, `blue.json`) from `palette/` to `data/`, and then feed `palette` with a file name with or without the json file extension (both `blue` and `blue.json` works). You can also create your own theme based on `default.json`.
