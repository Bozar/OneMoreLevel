# The Tindalos Hounds of the Baskervilles

[INPUT_HINT]

> It was a dark and stormy night. I did not speak with my friend since afternoon because he had criticized my previous work, A Study in Emerald, as a thriller by an untalented writer. As for now, he was quietly investigating a curious wooden figurine from Mycroft. "I don't think a man with an octopus head shaves his tentacles, my dear doctor." He put the figurine down and gave me an opened envelop. "On the other hand, can you read this letter for me? It's from the Baskervilles."

In order to beat the game, you need to hit the hound boss hard enough to drive it away. You may lose due to one of three reasons: your stick is broken, you are bitten too many times, or you are trapped in a stone cage.

## Stone Cage and Fog

There are eleven groups of cross shaped stone pillars (#) on the moor. They look like stone cages but one of them is broken, as it only has three pillars.

When you hit a hound (but not the hound boss or your doppleganger) with your stick, the hound disappears and a fog emerges from its position. The fog expands in a rhombus shape one grid per turn. It expands 5 turns and then shrinks in the reverse order. The duration of two fogs stack on each other. A fog disappears faster if it is within 2 grids from the hound boss.

A fog grid is shown as a thick dash (-). If the fog in a grid will disappear the next turn, it is shown as a plus sign (+). Beware that this might be a false alarm because in the next turn, the same grid could be covered by another expanding fog.

## Move, Attack and Wait

When outside a fog, press an arrow key to move one step in a cardinal direction. Press Space to wait. Unlike other dungeons, time is frozen here. Move, wait and attack cost no turn. The countdown timer at the top right corner of the main screen refers to the remaining hits of your stick before it breaks down (see below).

When in a fog, PC has one of six symbols:

* Three horizonal lines: You stand in a fog.
* A dotted rectangle: You stand in a fog which might disappear the next turn.
* One of four arrows: You have pressed an arrow key. Press another valid key to move into a diagonal grid.

A valid key is an arrow key that is vertical to your last input direction (for example: Right and Up, Down and Left). An invalid key includes an arrow key that is the same as or opposite to your previous input (for example: Up and Up, Left and Right) or Space. An invalid input resets PC to his normal state: three lines or a rectangle. Press Space in normal state to wait.

You cannot enter or leave a fog actively. The boundary of a fog acts like a wall. You either have to wait until a fog engulfs or spits you, or enter a grid that is about to change the next turn.

Moving into or waiting in an unbroken stone cage adds 3 to your doppleganger's hit point, to a maximum of 9. However, the game ends at once if you can no longer escape from a cage.

You perform an attack automatically after a valid move. You can only hit a target on your right hand.

Outside fog, move (x), hit (!) and ground (.):

    x ! | @ x | . @ | ! .
    @ . | . ! | ! x | x @

Inside fog, move (x), hit (!) and ground (.):

    . . . | @ . . | ! . @ | . . !
    . x . | . x . | . x . | . x .
    @ . ! | ! . . | . . . | . . @

Here is a tip to infer your attacking point. First you need to reach the start point. When outside a fog, it is a diagonal position to the target. When in a fog, it is on a straight line with the target and exactly one step away. Then link a line between you and your target, rotate it counterclockwise by 45 degrees. The nearest grid on the line is your destination.

You can hit a hound or the doppleganger both inside and outside a fog. The hound boss can only be hit when in a fog. Your stick lasts at most 24 hits. Every time you hit a target, the remaining hits are reduced by 1. You lose the game if your stick is completely broken.

## Hounds, the Hound Boss and Doppleganger

A hound (z, t) and the boss (Z, T) have two symbols based on its position.

* z, Z: The NPC is outside a fog.
* t, T: The NPC is inside a fog.

When outside a fog, an NPC moves in eight directions and bites PC diagonally. When inside a fog, an NPC moves and bites cardinally. A hound can see PC from 6 steps away. The boss always knows PC's position.

When an NPC hits PC, a PC's doppleganger is created if there isn't one already. The doppleganger is shown as a number. A newly created doppleganger has 9 hit points. Further bites reduce its hit point. You lose the game when the hit point decreases to 0. You can destroy the doppleganger as if it is a hound.

* -1 hp: A hound bites PC outside a fog.
* -2 hp: A hound bites PC inside a fog.
* -3 hp: The boss bites PC outside a fog.
* -4 hp: The boss bites PC inside a fog.

There are at most 10 hounds and 1 boss. A hound disappears after being hit. When there are 6 or fewer of them left, a new hound is respawned every turn.

The hound boss tends to stay in this world and chase PC forever. Its hit points slowly increases as time goes by and decreases when being hit by PC. When the boss has no hit point left, it disappears and you win the game.
