# Ninja Slayer

(Press Enter to view key bindings.)

> - Sorry, love. My heart has no room for another lady. She would slow me down.
> - If so, let me be the bone of your sword.
>
> An ordinary salaryman is now possessed by an ancient and powerful ninja soul. Can he kill all the ninjas in a Naraku Time to revenge for his wife and child?

You need to kill all ninjas in one turn. You have at most 24 turns and there is no way to restore turns. You lose the game either due to running out of time or being killed by a ninja. There are several hand crafted maps. Each of them contains grids that might be occupied by walls.

## Move, Approach, Bump & Kill

Press arrow keys to move into an unoccupied grid, approach an NPC, or bump into an adjacent NPC. Your interaction with an NPC varies according to the NPC's state. A ninja has two states: default (N) and passive (n). When you approach or bump into a ninja in default state, he becomes passive and steps back 1 grid automatically if possible.

    . . . .    When PC moves into grid 1, the
    @ 1 N 2    ninja steps back to grid 2. The
    . . . .    ninja cannot move if grid 2 is
               occupied by a wall or another
               ninja.

You can bump into 1 ninja at a time, but you can approach at most 3 ninjas with a single move.

    . A a .    When PC moves into grid 1, all
    @ 1 B b    3 ninjas, A, B and C, are
    . C c .    pushed back by 1 grid to a, b
               and c respectively.

When you approach or bump into a ninja in passive state, you kill the ninja. A dead ninja leaves one or more soul fragments (?) behind. A soul fragment lasts at most 8 turns. When its symbol becomes an exclamation mark (!), it means the fragment will disappear at the end of the current turn. Newly created fragments replace existing ones and reset the duration.

If you bump into a passive ninja, your victim leaves a soul fragment where he stands. If you approach a passive ninja, the ninja is pushed back by 1 grid if possible and then leaves at most 5 fragments. You can approach and kill at most 3 ninjas with one move in the same way mentioned above.

    . . . . .    When PC moves into grid 1,
    @ 1 n . .    the ninja is pushed back and
    . . . . .    killed. He leaves soul
                 fragments in grids marked with
    . . . ? .    question marks.
    . @ ? ? ?
    . . . ? .

Press Space to wait 1 turn.

## Naraku Time

You can enter Naraku time only by being adjacent to a passive ninja. When in Naraku time, you act normally but ninjas cannot act except step back responsively. Besides, your symbol turns into a number which shows your remaining ticks. Initially you have 9 ticks. The maximum tick decreases by 1 every 6 turns.

* 9 ticks: Turn 24 - 19
* 8 ticks: Turn 18 - 13
* 7 ticks: Turn 12 - 7
* 6 ticks: Turn 6 - 1

The turn counter is frozen so long as you have ticks left. When you are running out of ticks, you leave Naraku time and your current turn ends. You can also leave early by pressing Space.

Move into a grid that is not covered by a soul fragment costs 1 tick. Actions below cost no tick.

* Move into a grid with a soul fragment.
* Approach or bump into a ninja.

## NPC AI & Enemy Respawn

A ninja approaches PC by 1 step if he is close to PC. The maximum range equals to (6 + 2 * (dead ninjas in the last turn)). He can also one shot kill PC in melee. At the start of a turn, a ninja resets to default state and new ninjas respawn around PC.
