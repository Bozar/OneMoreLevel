class_name Game_SpriteTypeTag
# SpriteType.set_sprite_type() requires a string tag.


const DEFAULT := "default"
const DEFAULT_1 := "default_1"
const DEFAULT_2 := "default_2"
const DEFAULT_3 := "default_3"

const ACTIVE := "active"
const ACTIVE_1 := "active_1"
const ACTIVE_2 := "active_2"
const ACTIVE_3 := "active_3"
const ACTIVE_4 := "active_4"
const PASSIVE := "passive"
const PASSIVE_1 := "passive_1"

const UP := "up"
const DOWN := "down"
const LEFT := "left"
const RIGHT := "right"

const ZERO := "zero"
const ONE := "one"
const TWO := "two"
const THREE := "three"
const FOUR := "four"
const FIVE := "five"
const SIX := "six"
const SEVEN := "seven"
const EIGHT := "eight"
const NINE := "nine"

const ORDERED_SPRITE_TYPE := [
	ZERO, ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE,
]


static func convert_digit_to_tag(digit: int) -> String:
	if (digit > -1) and (digit < ORDERED_SPRITE_TYPE.size()):
		return ORDERED_SPRITE_TYPE[digit]
	return ZERO
