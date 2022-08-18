# Desert

[INPUT_HINT]

You need to bump and collect 3 quality spices (*) from a living sandworm. Press Space to show how many spices you have so far, but you cannot wait in desert, which makes the job a little bit harder.

A sandworm has a head (diamond), a tail (-) and body segments (+). The third, fourth and fifth segment contains a common spice (?) or a quality spice (*). Every sandworm has at most one quality spice. You can only bump segments that have spices. Other sandworm parts (head, body and tail) act like indestructible walls.

There are at most 2 sandworms in the desert. A new sandworm always appears in a grid that is at least 5 steps away from PC or another sandworm. It is more likely to appear in a grid surrounded by fewer dunes.

Every turn a sandworm moves one step in a random direction. It has a higher chance to move in a straight line. Eventually it will tunnel into ground and leave a wall of dunes behind. A sandworm spends fewer time on the surface if: (1) It is immobilized; (2) It has spices, the more the better.

Dunes are composed of sand walls (#) and spices (?). They are created by a living sandworm. The more spices a sandworm has, the more spices will be left behind. You can bump and destroy a wall or bump and collect a spice just as from a sandworm. You do not move when bumping. It can be used as a poor man's waiting key.

You might lose the game due to one of three reasons.

Firstly, you can survive in desert for at most 24 turns. Moving and bumping costs 1 turn. Starting your turn beside a sandworm costs an extra `2N - 1` turns, where `N` is the number of adjacent sandworm segments. Bumping a common or quality spice restores 6 turns. You lose if you have not collected 3 spices when your last turn ends.

Secondly, PC's symbol turns into a rectangle when being adjacent to a sandworm's head. The game ends if the sandworm intends to move into PC's position the next turn.

Lastly, if you are surrounded by four solid blocks when your turn starts, you fail automatically. A solid block refers to a sandworm segment or an edge of the dungeon. See digraph below.

    . # .   North (O): Sand wall.
    . @ +   East (X): Sandworm segment.
    + + +   South (X): Sandworm segment.
    [Alive] West (O): Floor.

    % ? .   North (O): Common spice, dune.
    % @ *   East (X): Quality spice, sandworm.
    % - +   South (X): Sandworm tail.
    [Alive] West (X): Edge of the dungeon.

    % s +   North (X): Sandworm head.
    % @ +   East (X): Sandworm segment.
    % - +   South (X): Sandworm tail.
    [Dead]  West (X): Edge of the dungeon.
