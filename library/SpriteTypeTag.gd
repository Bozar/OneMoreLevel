const DEFAULT: String = "default"
const DEFAULT_1: String = "default_1"
const DEFAULT_2: String = "default_2"
const DEFAULT_3: String = "default_3"

const ACTIVE: String = "active"
const ACTIVE_1: String = "active_1"
const ACTIVE_2: String = "active_2"
const ACTIVE_3: String = "active_3"
const ACTIVE_4: String = "active_4"
const PASSIVE: String = "passive"
const PASSIVE_1: String = "passive_1"

const UP: String = "up"
const DOWN: String = "down"
const LEFT: String = "left"
const RIGHT: String = "right"

const ZERO: String = "zero"
const ONE: String = "one"
const TWO: String = "two"
const THREE: String = "three"
const FOUR: String = "four"
const FIVE: String = "five"
const SIX: String = "six"
const SEVEN: String = "seven"
const EIGHT: String = "eight"
const NINE: String = "nine"


# Helper functions.

const ORDERED_SPRITE_TYPE: Array = [
    ZERO, ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE,
]


func convert_digit_to_tag(digit: int) -> String:
    digit = digit if digit < ORDERED_SPRITE_TYPE.size() else 0
    return ORDERED_SPRITE_TYPE[digit]
