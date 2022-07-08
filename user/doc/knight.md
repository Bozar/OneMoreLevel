# Silent Knight Hall

[INPUT_HINT]

Your mission is to sneak into the Silent Knight Hall and assassinate the knight boss. However, the boss will not show up until you have killed three captains (C). There is a counter that behaves like a wall (#) and shows the number of dead captains. Whether or not to kill knights (k) is your own choice.

Press arrow keys to move, roll over or attack. Press Space to wait. Every action (move, roll over, attack and wait) costs exactly 1 turn. When an enemy dies, you gain 6 turns. You have at most 24 turns. You lose the game either because of running out of time or being killed by an enemy.

An enemy has three states: normal, alert and fatigued. In normal state, his symbol is an alphabet. Such an enemy acts like a wall. You cannot bump attack or pass through him. He might take one of three actions.

* Approach you if he can see you.
* High chance: Wait one turn.
* Low chance: Approach a knight captain or boss.

If an enemy starts his turn being adjacent to you, he becomes alert (!) and waits one turn. An upside-down exclamation mark means an alert elite (captains or the boss). Such an enemy will attack grids marked by double excmamation marks (danger zone) the next turn and kills everyone in the zone. Your symbol turns into a solid rectangle if you are in danger. The game prevents you from staying inside if possible, otherwise it ends automatically. Bump an alert enemy and roll over to the other side if the destination is not occupied.

    @ ! .   <-- Roll over.
    @ ! #   <-- Cannot roll over. The grid is blocked by wall.
    @ ! K   <-- Cannot roll over. The grid is blocked by knight.

An enemy becomes fatigued (?) and waits one turn after attacking. Similarly, an upside-down question mark means an elite. Bump attack a fatigued enemy to kill him. Kill knights (K) and captains (C) with 1 hit. The boss requires 3 hits to kill. He has three symbols (S, P, D) to show how many hits he has taken (S: 0 hit, P: 1 hit, D: 2 hits).

A knight can see you from 8 grids away. The sight range of an elite (captain or boss) is 12 grids. An elite attacks more than one grids. The boss attacks twice before cooling down in his final form (D).

After rolling over an enemy, your symbol turns into a dotted rectangle. It means you are sneaking and an enemy cannot see you unless you are adjacent to him. You reveal yourself right after killing an enemy.
