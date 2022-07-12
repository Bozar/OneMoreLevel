# Frog Princess and the Spear of Love

[INPUT_HINT]

> Our princess and her twelve knights are turned into frogs by an evil wizard. Finn the human and Jack the dog, take the spear that wounds and heals someone with the same stab. Venture into swamp, remove the curse and save our kingdom from doom.

Frog princess and frog knights come in waves. Hit them with the spear to remove the curse. You might lose due to running out of turns or being swallowed by a frog.

## Move in Swamp

Strips of land (#, grey hashtag) are surrounded by swamp (-, grey dash). PC has three symbols to show his current state.

* @: You stand on land.
* Three horizonal lines: You stand in swamp.
* A dotted rectangle: You stand in swamp. Your next movement out of the swamp costs 2 turns.

Press arrow keys to move one step if there are no frogs nearby. Moving out of land costs 1 turn. Leaving swamp costs 1 or 2 turns based on an internal counter. The counter starts from 0 and adds by 1 every time before you leave a swamp grid. When it reaches 3, moving costs 2 turns and the counter resets to 0. Otherwise it costs 1 turn to move. Hitting a frog also resets the counter to 0. Please beware that the counter is only affected by moving away from swamp and hitting a frog. It has nothing to do with waiting or any other factors.

Press Space to wait 1 turn.

## Hit a Frog

Frog knight (f) and frog princess (P) follow the same rules most of the time. We use the word frog to refer to both of them from now on unless specified otherwise. You hit a frog (instead of moving) by pressing arrow keys if it is the closest target that is on a straight line with you and is no more than 2 steps away. In the digraph below, you can either move to grid 1 or hit frog A, B or C, but not D or E.

    . D 1 . .
    . A @ B E
    . . . . .
    . . C . .

Hitting a frog restores 8 turns. You have at most 24 turns. Actions (move, wait, and hit) take time. You lose the game if running out of turns.

You can only see frogs that are within 3 steps. After hitting a frog knight, a small area around it becomes visible permanently. Lands in this area will never be submerged by swamp (see *Five Waves of Frogs*).

## Frog AI

A frog has three sets of actions.

* Wait 1 to 3 turns. After waiting, take an action below if possible. Then wait again.
* Grapple and swallow PC.
* Move to a diagonal grid.

A frog grapples and swallows PC if: (1) PC does not wait last turn by pressing Space. (2) PC is within 2 steps from the frog. (3) If the frog and PC are on a straight line, it also requires that there are no other frogs between them. In the digraph below, frog A, B, C and D can grapple PC, but not E, as it is blocked by D.

    . A . .
    B . . .
    C @ D E
    . . . .

If a frog cannot grapple PC, it jumps diagonally to a grid exactly 2 steps away. If it is far away from PC, it tends to move closer. Otherwise it moves randomly.

## Five Waves of Frogs

Frogs emerge in five waves. There is a counter in the bottom right corner of the map which shows the current wave number. The counter acts as a land grid and it cannot be submerged.

Wave 1. This is the initial wave. There are 8 frog knights. When 4 of them disappear due to being hit, enter wave 2.

Wave 2. Some land is submerged by swamp. The remaining frog knights disappear. Princess appears the first time. Hit the princess to enter wave 3.

Wave 3. Once again there are 8 knights. Hit 4 of them to enter wave 4.

Wave 4. More land is submerged. The princess reappears. Hit the remaining 4 knights to enter wave 5. If you hit the princess when there are still knights in the dungeon, she reappears the next turn.

Wave 5. This is the final wave. Hit the frog princess to beat the game.
