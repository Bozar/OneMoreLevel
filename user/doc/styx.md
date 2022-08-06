# Styx Ferryman

[INPUT_HINT]

## Winning and Losing

There are 3 lost harbors in the mist of Styx. In order to beat the game, you need to reach at least one of them in 24 turns. You lose the game if you have not reached any harbor when the last turn ends.

## Moving and Waiting

Press arrow keys to sail a boat in Styx, which is composed of arrows. You cannot enter a grid with an arrow that is opposing to your input direction. This is an invalid input. All other arrow key inputs are valid. Such a valid input, no matter how long distance it covers, costs 1 turn.

You move 1 step if the destination has a perpendicular arrow. If you move along the water flow, it may carry you to a far away place.

    1 2 3 4 5 6
    → → → → → ↑

Suppose you start from grid 2. You cannot press left arrow key to enter grid 1, because it has a right arrow which is opposing to left arrow key. If you press right arrow key, the water flow pushs you all the way to grid 5. When in grid 5, press right arrow key again to enter grid 6.

Press Space to wait 1 turn. Waiting also randomize the directions of all arrows in the dungeon.

## Field of View and Lighthouse

Your field of view is a rhombus area. Grids outside this area are invisible. Grids on the edge are dark grey. Grids inside are grey. Initially, you can see 3 grids around you. Whenever you press Space, your sight range reduces to 2, and it will increase to 3 grids after 3 turns.

There is a lighthouse in the center of the map, which is shown as a digit. The digit is a countdown timer. When it reduces to 0, your sight range restores to normal. The lighthouse is always visible. It blocks movement. There is no water flow around it. Its color is dark grey by default. However, if you are within 6 or fewer grids to a harbor, the lighthouse turns to grey.

The field of view is updated once at the start of a turn. You cannot examine surroundings when being carried away by water flow.

    1 2 3 4 5 6 7 8 9
    → → → → → → → → ↑

Suppose you start from grid 1, press right arrow key to move to grid 8. You can only see things around grid 1 and 8, but nothing in between.

## Reaching a Harbor

A harbor is an impassable building similar to the lighthouse. There are 3 harbors in Styx. They are all invisible initially. Harbors are 7+ grids away from each other and PC's start point.

If a harbor shows up at the edge of your field of view, it is a dark grey question mark (?). You cannot remember the position of such a harbor. If you move away, the harbor becomes invisible again.

If a harbor appears inside your field of view, it turns into a grey question mark (?). It remains visible no matter where you go from now on.

In order to reach a harbor, you need to end your turn in an adjacent grid. The harbor becomes a grey exclamation mark (!) and remains visible. Beating the game requires reaching one harbor. Try to discover more of them before your time runs out as a bonus quest.
