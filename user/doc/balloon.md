# Balloon Travellers

[INPUT_HINT]

> Sit in a hot balloon and fly across a power station in a speed race. Reach designated places to earn points. Do not bump into tower like chimneys when possible.

During the balloon race, you need to earn at least 3 points by ending your turn at a beacon marked with a question mark (?). You have at most 24 turns. You lose the game when running out of turns.

A beacon has three states:

* Unexplored: A light colored question mark (?).
* Active: A light colored plus sign (+).
* Inactive: A dark colored plus sign (+).

Reaching an unexplored beacon restores one or more turns and grants you 1 point. Then it becomes inactive. Visit an active beacon restores the same amount of turns as above, but it grants you no point. All inactive beacons become active when an unexplored or active beacon is reached.

The amount of turn restoration depends on the number of unexplored beacons:

* 3+ beacons: Restore 1 turn.
* 2 beacons: Restore 3 turns.
* 1 beacon: Restore 5 turns.

You can move over the border of the dungeon and reappear on the opposite side. When there is a chimney (#) in the way, the balloon will try to step back one grid if possible.

Every turn the balloon moves two steps. Firstly, it goes with the wind. The wind direction is indicated by an arrow and it changes every 3 turns. [1] Secondly, the balloon responds to your key input, which could be one of four directions (arrow keys) or waiting (Space).

Indicators on the top left corner show the direction and duration of the current wind wave, and the direction of the next wave.

[1] The wind direction is more likely to change into its vertical counterparts: from left/right to up/down, or vice versa. And it is less likely to remain unchanged for another three turns. It never changes to the opposite direction: between left and right, or up and down.
