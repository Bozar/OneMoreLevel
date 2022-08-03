# Ninja Slayer

[INPUT_HINT]

> - Sorry, love. My heart has no room for another lady. She would slow me down.
> - If so, let me be the bone of your sword.
>
> An ordinary salaryman is now possessed by an ancient and powerful ninja soul. Can he kill all ninjas in a Naraku Time to revenge for his wife and child?

To beat the game, you need to stop time and kill all ninjas before time starts to flow again. You lose the game either due to running out of time or being hit the second time by a ninja.

## Dungeon Environment

The dungeon is composed of three columns. The left and right columns are indicators to show your current level. An empty row means you are at an empty grid. A row with question marks (?) means you are at a grid with a soul fragment, of which the symbol is also a question mark (?).

The middle column is battle ground. When the game starts, you stand on a static platform at the bottom of an elevator shaft. Underneath the platform is your hit point bar. The bar has 2 blocks. When you take 1 hit from a ninja, the right block is depleted. The second hit depletes the left block and kills you.

## PC Moves outside Time Stop

### PC Stands on Ground

When standing on ground, press left or right arrow key to move 1 step horizontally, and press up arrow key to jump 2 grids upwards. Down arrow key has no effect in this case.

If your path is blocked by a ninja (left, right, or within 2 grids upwards), you stop right before the ninja, hit him and stop time (more on this below: *PC Moves inside Time Stop*, *PC Hits a Ninja*); otherwise you move to the destination, your turn ends and the countdown timer on the top right corner of the screen reduces by 1 turn. If you do not want to move, press Space to wait 1 turn. You have at most 24 turns. The game ends when you are running out of time.

Press left/right to hit ninja 1 or move to grid 2.

    1 @ 2
    # # #

Press up to hit ninja 3/4, or to jump to grid 5.

    . | 4 | 5
    3 | . | .
    @ | @ | @
    # | # | #

### PC Floats in Mid-air

When floating in mid-air, 2 grids right below you turn into short dashes. They are your falling trajectory. Besides, if there is a soul fragment in the trajectory, its symbol changes from a question mark (?) to an exclamation mark (!).

Press left or right arrow key to move 1 step horizontally and then fall down 2 grids. Press down arrow key to fall down 2 grids without moving horizontally. Press Space also results in falling down 2 grids, but you cannot hit a ninja in this way, see below. Up arrow key has no effect in this case.

Similarly as above, if your path is not blocked by a ninja, you spend 1 turn to move to the destination; otherwise you hit the ninja and stop time unless you press Space key.

Press right to hit ninja 1/2/3 or move to grid 4.

    @ 1 | @ . | @ . | @ .
    . . | . 2 | . . | . .
    . . | . . | . 3 | . 4
    . . | . . | . . | . .

Press down to hit ninja 5/6 or move to grid 7.

    @ | @ | @
    5 | . | .
    . | 6 | 7
    . | . | .

If grid 8 is occupied by a ninja, press Space to move to grid X, otherwise to move to grid 8.

    @
    X
    8
    .

## PC Moves inside Time Stop

When you hit a ninja outside time stop, you freeze the countdown timer immediately and your symbol turns into a digit. It shows how many remaining ticks you have in the current stop. The maximum ticks equals to `6 - PC_HIT_POINT`.

Press left or right arrow key to move 1 step horizontally, and up or down arrow key to move 2 grids vertically. If you hit a ninja in the way or the first grid in your path has a soul fragment (As mentioned above, its symbol is a question mark (?).), this moving or attacking costs no tick, otherwise your tick is reduced by 1. You end your current turn when there is no ticks left. You can also press Space to let time flow right away.

## PC Hits a Ninja

If a ninja blocks your moving path, you stop right before the ninja, hit him, remove him from the game, and stop time. Besides, a dead ninja may leave a soul fragment behind. The soul fragment is shown as a question mark (?). Its symbol turns into a exclamation mark (!) when it is in a falling trajectory.

There are two types of ninjas: common ninja (N, n) and shadow ninja (S, s). An uppercase letter means the ninja is on a grid that has a soul fragment.

When you hit a common ninja, he leaves behind a soul fragment if there are no shadow ninjas on the same row or column with him. Otherwise, he removes the fragment beneath him (if there is any) instead. When you hit a shadow ninja, he removes the fragment beneath him (if there is any).

Removing a common or shadow ninja due to being idle for 1 turn (see below, *General AI*) does not add or remove a soul fragment.

## Ninja AI

### General AI

All ninjas act after PC. If a ninja neither moves nor attacks in his turn, he will be removed at the end of PC's next turn. (See an example below.) A ninja has a falling trajectory that is 2 grids long just as PC. He falls down at the end of his turn.

* Turn 1: [PC acts.] -- [Ninja 1 waits.] -- [Ninja 2 acts.]
* Turn 2: [PC acts.] -- [Ninja 1 is removed after PC's action.] -- [Ninja 2 acts.]

### Common Ninja AI

A common ninja may perform one of three actions at the start of his turn.

Action 1. Hit PC if he is adjacent to PC. His symbol changes from n to x for one turn.

Action 2. When on ground, if he is more than 2 steps away from PC horizontally, try to move 1 step towards PC. Otherwise, jump up if there is at least one unoccupied grid above. A ninja can jump at most 2 grids high. PC is hit if he blocks the jumping path. If another NPC blocks the vertical or horizontal path, the ninja cannot move to his destination.

Action 3. When in mid-air, try to fall down 2 grids. Same as action 2, PC is hit if he blocks the way, and the ninja can be blocked by his allies.

### Shadow Ninja AI

At the start of a shadow ninja's turn, remove the soul fragment beneath him if there is any. Then he may perform one of two actions.

Action 1. When in mid-air, fall down 2 grids if possible. Remove fragments along the way.

Action 2. When on ground, if he is not in the same column with PC, try to move 1 step horizontally towards PC. Remove fragments along the way.

## Respawn Ninjas

The elevator shaft holds at most 13 ninjas. If the number of ninjas does not reach its maximum, new ones appear at the top three rows of the shaft when PC's turn ends. There can be at most 4 new common ninjas every turn. If currently there are fewer than 4 shadow ninjas, the first common ninja is replaced by a shadow ninja. A new shadow ninja tends to appear in a row that has the most soul fragments. Besides, he is less likely to be in the same column with another shadow ninja.

In order to beat the game, first you need to hit a ninja and enter time stop. Then you have to kill all remaining ninjas, the number of which ranges from 3 to 12, within 4 ticks.
