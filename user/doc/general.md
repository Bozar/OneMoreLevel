# General Help

[INPUT_HINT]

## About This Game

One More Level is a turn-based Roguelike game made with Godot engine. It is available on GitHub. The GUI font, Fira Code, is created by Nikita Prokopov. The tileset, curses_vector, is created by DragonDePlatino for Dwarf Fortress.

You can play One More Level either locally (which is an executable file) or as a HTML5 game on itch.io. You can change most settings (except `palette`, see below) when playing online.

Every time you start the game, One More Level presents you with a theme dungeon of unique mechanics and goals. This idea comes from HyperRogue, one of the most bizarre and fascinating games I have ever played. You can beat the game in five minutes, so it never hurts to go down just one level deeper.

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
