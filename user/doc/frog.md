# Frog Princess and the Spear of Love

(Press Enter to view key bindings.)

> Our princess and her knights are turned into frogs by an evil wizard. Finn the human and Jack the dog, take the spear that wounds and heals someone with the same stab. Venture into the swamp, remove the curse and save our kingdom from doom.

There is one frog princess and twelve frog knights that come in five waves. Remove all their curses to beat the game. You might lose due to running out of turns or being swallowed by a frog.

## Move in Swamp

Strips of land (#, grey hashtag) are surrounded by swamp (-, grey dash) in the dungeon. PC has four symbols that shows his current state.

* @: You stand on land.
* Three horizonal lines: You stand in swamp.
* Semi-tranparent rectangular: You stand in swamp. Your next movement out of the swamp costs 2 turns.
* Solid rectangular: You are grappled. You will be swallowed the next turn.

Press arrow keys to move one step if there are no frogs nearby. Moving out of land always costs 1 turn. Leaving the swamp costs 1 or 2 turns based on an internal counter. The counter starts from zero and adds by one every time before you leave a swamp grid. When it reaches three, moving costs 2 turns and the counter resets to zero. Otherwise it costs 1 turn to move. Hitting a frog also resets the counter to zero. (Please beware that the counter is only affected by moving out of swamp and hitting a frog. It has nothing to do with grapple, wait or any other factors.)

Press Space to wait 1 turn.

## Hit a Frog

Frog knight (f) and frog princess (P) follow the same rules most of the time. We use the word frog to refer to both of them from now on unless specified otherwise. You hit a frog (instead of moving) by pressing arrow keys if it is the closest target that is on a straight line with you and no more than 2 steps away. In the digraph below, you can either move to grid 1 or hit frog A, B or C, but not D or E.

    . D 1 . .
    . A @ B E
    . . . . .
    . . C . .

Hitting a frog costs 1 turn and restores 8 turns. You have at most 24 turns. Actions (move, wait, hit, break free) take time. You lose the game if running out of turns.

## Frog AI

A frog has three sets of actions.

* Wait 1 to 3 turns. After waiting, take one of the two actions below if possible. Then wait again.
* Grapple PC and swallow him the next turn.
* Move to a diagonal grid that is 2 steps away.

A frog grapples PC if he is within 2 steps away and he does not wait last turn. If the frog and PC are on a straight line, it also requires that there are no other frogs inbetween them. In the digraph below, frog A, B and C can grapple PC, but not D, as it is blocked by E.

    . A . .
    B . . .
    C @ E D
    . . . .

When grappled, PC's symbol turns into a solid rectangular. You can press Space to wait. If so, you will be swallowed and lose the game the next turn. You can also press arrow keys to break free. More specifically, you can only move 1 step into a grid that is neither occupied by another frog, nor is within 2 steps from the frog (marked by double exclamation marks). You cannot hit a frog under this circumstance. Breaking free always costs 2 turns.

A frog usually swallows its target (no matter whether it is still there or not) the next turn after grappling. However, a frog does not swallow PC if he is forced to pass 1 turn due to moving out of swamp. It swallows PC 2 turns after grappling instead.

If a frog cannot grapple or swallow PC, it moves diagonally to a grid exactly 2 steps away. If it is far away from PC, it tends to move closer. Otherwise it moves randomly. A frog prefers moving into a swamp grid rather than land.

## Beat Five Waves of Frogs

Frog knights and frog princess come in five waves. There is a counter in the bottom right corner of the map which shows the current wave number. The counter acts as a swamp grid.

Wave 0. This is the initial wave. There are 8 frog knights. When 4 of them disappear due to being hit, enter wave 1.

Wave 1. Some land is submerged by swamp. The remaining frog knights disappear. Princess appears the first time. Hit the princess to enter wave 2.

Wave 2. Once again there are 8 knights. Hit 4 of them to enter wave 3.

Wave 3. More land is submerged. The princess reappears. Hit the remaining 4 knights to enter wave 4. If you hit the princess when there are still knights in the dungeon, she reappears somewhere close to PC.

Wave 4. Hit the frog princess to beat the game.
