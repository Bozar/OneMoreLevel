# General Help

[INPUT_HINT]

## About This Game

One More Level is a turn-based Roguelike game made with Godot engine. It is available on GitHub. The GUI font, Fira Code, is created by Nikita Prokopov. The tileset, curses_vector, is created by DragonDePlatino for Dwarf Fortress.

You can play One More Level either locally (which is an executable file) or as a HTML5 game on itch.io. However, you cannot change settings (more details below) when playing online.

Every time you start the game, One More Level presents you with a theme dungeon of unique mechanics and goals. This idea comes from HyperRogue, one of the most bizarre and fascinating games I have ever played. You can beat the game in five minutes, so it never hurts to go down just one level deeper.

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

## Export the Game

If you want to export One More Level using Godot engine by yourself, first you need to download the project from GitHub (see above, About This Game). You also have to tweak export settings to filter certain files. In the GitHub repository, refer to `misc/export.md` for more information.
