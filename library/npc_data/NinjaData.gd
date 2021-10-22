class_name Game_NinjaData


const MIN_X := 7
const MAX_X := 14
const MIN_Y := 0
const MAX_Y := 13
const GROUND_Y := 12

const LEVEL_1_Y := 3
const LEVEL_2_Y := 6
const LEVEL_3_Y := 9

const PC_SPEED := 2
const PC_SIGHT := 6
const MAX_TIME_STOP := 4
const MAX_PC_HP := 2

const NINJA_SPEED := 2
const ATTACK_RANGE := 1
const VERTICAL_NINJA_SIGHT := 3
const MAX_NINJA_HP := 1

# With 4 ninjas per level and 3 levels in all, we have 12 ninjas at the start of
# the game. However, sometimes the formation is in such a coincidenct that all
# the initial ninjas can be easily killed in one turn. In order to avoid this,
# we set MAX_NINJA to 13. Therefore, a new ninja will be respawned at the end of
# the first turn. He is probably away from his companions and he must be a
# shadow ninja. Refer to NinjaProgress.end_world().
const MAX_NINJA_PER_LEVEL := 4
const MAX_NINJA := 13
# const MAX_NINJA := 12
const MAX_SHADOW_NINJA := 3
