# The Tindalos Hounds of the Baskervilles

(Press Enter to view key bindings.)

> It is a dark and stormy night. I does not speak with my friend since afternoon because he criticized my previous work, A Study in Emerald, as a thriller by an untalented writer. As for now, he is quietly investigating a curious wooden figurine from Mycroft. "I don't think a man with an octopus head shaves his tentacles, my dear doctor." He puts the figurine down and gives me an opened envelop. "On the other hand, can you read this letter for me? It's from the Baskervilles."

You need to survive three attacks from the hound leader. You may lose the game due to one of three reasons: running out of turns, being bitten too many times, or being trapped in a stone cage.

## Stone Cage and Fog

There are eleven groups of cross shaped stone pillars (#) on the moor. They look like eleven stone cages but one of them is broken, as it only has three pillars. The broken cage acts as a hound leader indicator. A question mark (?) means that the leader will appear soon. An exclamation mark (!) means that the leader is hit once.

When you hit a hound (but not the hound leader or your doppleganger) with your stick, the hound disappears and a fog emerges from its position. The fog expands in a rhombus shape one grid per turn. It expands 5 turns and then shrinks in the reverse order. The duration of two fogs stack on each other. A fog grid is shown as a thick dash (-). If the fog in a grid will disappear the next turn, it is shown as a plus sign (+). Beware that this might be a false alarm because in the next turn, the same grid could be covered by another expanding fog.

## Move, Attack and Wait

When outside a fog, press an arrow key to move one step in a cardinal direction. Press Space to wait one turn.

When inside a fog, PC has one of six symbols:

* Three horizonal lines: You stand in a fog.
* A porous rectangle: You stand in a fog which might disappear the next turn.
* One of four arrows: You have pressed an arrow key. Press another valid key to spend one turn and move into a diagonal grid.

A valid key refers to an arrow key that is vertical to your last input direction (for example: Right and Up, Down and Left). An invalid key includes an arrow key that is the same as or opposite to your previous input (for example: Up and Up, Left and Right) or Space. An invalid input resets PC to his normal state: a porous or solid rectangle. Press Space in normal state to wait one turn.

You cannot enter or leave a fog actively. The boundary of a fog acts like a wall. You either have to wait until a fog engulfs or spits you, or enter a grid that is about to change the next turn.

You perform an attack automatically after a valid move. You can only hit a target on your right hand.

Outside fog, move (x), hit (!) and ground (.):

    x ! | @ x | . @ | ! .
    @ . | . ! | ! x | x @

Inside fog, move (x), hit (!) and ground (.):

    . . . | @ . . | ! . @ | . . !
    . x . | . x . | . x . | . x .
    @ . ! | ! . . | . . . | . . @

Here is a tip to infer your attacking point. First you need to reach the start point. When outside a fog, it is a diagonal position to the target. When inside a fog, it is on a straight line with the target and exactly one step away. Then link a line between you and your target, rotate it counterclockwise by 45 degrees. The nearest grid on the line is your destination.

When you hit a target (a hound, the hound leader, or your doppleganger), it disappears and you restore 2 turns. Such a hit has other effects, including but not limit to emerging a fog. More on this below.

As mentioned above, a valid move or wait, whether inside or outside a fog, costs 1 turn. You have at most 24 turns. You lose the game if running out of time. In addition to restore turns by attacking, every time you move into or wait inside an unbroken stone cage grants 4 turns. However, the game ends at once if you can no longer escape from a cage.

## Hound AI and Doppleganger



## Hound Respawn


