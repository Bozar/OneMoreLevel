class_name Game_DungeonSize


const MAX_X := 21
const MAX_Y := 15

const CENTER_X := 10
const CENTER_Y := 7

const ARROW_MARGIN := 32


static func init_dungeon_board(dungeon: Dictionary, init_value = null) -> void:
    if dungeon.size() > 0:
        return

    for x in range(0, MAX_X):
        dungeon[x] = []
        if init_value == null:
            dungeon[x].resize(MAX_Y)
        else:
            for _i in range(0, MAX_Y):
                dungeon[x].push_back(init_value)
