# Desert

[→: Key bindings | ←: General help]
[↑, PgUp: Scroll up | ↓, PgDn: Scroll down]

You need to bump and collect 3 quality spices (*) from a living sandworm. Press Space to show how many spices you have so far, but you cannot wait in desert, which makes the job a little bit harder.

A sandworm has a head (diamond), a tail (-) and body segments (+). The third, fourth and fifth segment contains spice (?) or quality spice (*). Every sandworm has at most one quality spice. You can only interact with segments that have spices. Other sandworm parts (head, body and tail) act like indestructible walls.

There are at most 2 sandworms in the desert. A new sandworm always appears in a grid that is at least 5 steps away from PC or another sandworm. It is more likely to appear in a grid without a dune. Every turn a sandworm moves one step in a random direction. Eventually it will tunnel into ground and leave a wall of dunes behind. The more spices a living sandworm has, the more likely are the dunes to contain spices. A sandworm spends fewer time on the surface if: (1) It is immobilized. (2) It has spices, the more the better.

A wall of dunes is composed of sand walls (#) and spices (?). You can bump and destroy a wall block or collect a spice just as from a sandworm. You do not move when bumping. It can be used as poor man's waiting key.

You might lose the game due to one of three reasons.

You can survive in desert for at most 24 turns. Every spice and quality spice extends your remaining time by 5 turns.

PC's symbol changes into a rectangle when being adjacent to a sandworm's head. The game ends if the sandworm intends to move into PC's position the next turn.

If you are surrounded by four solid blocks when your turn starts, the game ends automatically.

    . # .   North (O): Sand wall.
    . @ +   East (X): Sandworm segment.
    + + +   South (X): Sandworm segment.
            West (O): Floor.

    % ? .   North (O): Spice.
    % @ *   East (O): Quality spice.
    % - +   South (X): Sandworm tail.
            West (X): Edge of the dungeon.

    % s +   North (X): Sandworm head.
    % @ +   East (X): Sandworm segment.
    % - +   South (X): Sandworm tail.
            West (X): Edge of the dungeon.
