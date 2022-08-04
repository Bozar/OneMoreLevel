# SnowRunner

[INPUT_HINT]

## Turn Restoration Cheatsheet

* Onload a unit of goods: 4 turns
* Offload a unit of goods: 16 turns
* Pick up a passenger: 4 turns
* Drop off a passenger: 8 turns

## Winning and Losing

To beat the game, you need to deliver goods by truck from a garage to 5 different places in a snow covered city, and then return to the garage to call it a day. You have at most 24 turns. You lose the game if you fail to return to the starting point with enough deliveries when the last turn ends.

## A Cab and Three Slots

Your truck is composed of a cab and three slots. The cab is an arrow which shows the current driving direction. A slot has four symbols and three related states.

* An underscore: An empty slot.
* Three short dashes: Carrying a unit of goods.
* A smiling face, either opaque or transparent: Carrying a passenger.

Press Space to highlight interaction points on the map. When doing so, the cab turns into a digit which shows the number of successful deliveries. Press Space again or move around to turn off highlight. Switching highlight costs no turn.

## Semi-auto Driving

As mentioned above, your cab is a direction arrow. You cannot move backwards by pressing the arrow key opposing to the current moving direction. Press the arrow key of the same direction to drive along the road automatically. The truck stops only when the game requires an extra input from player. Driving in a straight line by 1 grid costs 1 turn.

    → . . _

In the diagram above, you cannot press Left to drive backwards. Press Right to drive to a crossroad (a thick dash, more on this below). You cannot stop halfway when going rightwards and you are forced to spend 3 turns.

Your truck sticks to the right side of the road when driving. Semi-auto driving stops when the cab covers a crossroad grid, the symbol of which is a thick dash.

    . . . D C . .
    → . . A B . .
    . . . 1 . . .

In the diagram above, suppose A, B, C and D are crossroad grids and 1 is a normal grid.

* Press Right to drive all the way to grid A.
* Grid A: Press Down to turn right and enter grid 1, or press Right to enter grid B.
* Grid B: Press Up to turn left and enter grid C.
* Grid C: Press Left to turn left and enter grid D.
* Grid D: Unfortunally you cannot turn left again because grid A is occupied by a slot.

Turning a corner costs 1 to 3 turns.

* 1 turn: Carry 0 to 1 unit of goods.
* 2 turns: Carry 2 units of goods.
* 3 turns: Carry 3 units of goods.

There is snow on the ground. Its symbol is an asterisk (*). Driving over a snow grid costs 1 extra turn and the snow is removed. Snow grids appear and disappear at their own pace, which may even happens during semi-auto driving.

## Onloading and Offloading Goods

A building is composed of walls and interaction points. The symbol of a wall is always a number sign (#). There are four types of interaction points on the map.

* Door: a plus sign (+).
* Passenger: P.
* Garage: G.
* Offloading zone: a solid rectangle.

The garage (G) is on the right side of your starting point. Bump it to onload goods. Then one of the slots changes from an underscore to three short dashes. Bumping once restores 4 turns. You cannot onload goods if all three slots are occupied. Nor does the truck stop by the garage in this case. The garage has only 5 units of goods. Bump it the sixth time has no effect.

A successful delivery requires you to onload a unit of goods from the garage and put it down at an offloading zone. After you have made 5 deliveries, you need to go back to the garage and bump it one last time. This time, all the slots must be empty. The truck does not stop by the garage if you have delivered 5 units of goods and one or more slots are occupied.

The symbol of an offloading zone is a solid rectangle. The truck stops by there only if you are carrying at least one unit of goods. Bump the zone to offload a unit of goods and you restore 16 turns. There are five offloading zones but at most two of them appear at the same time. The first two zones show up at the start of the second turn.

## Picking Up and Dropping Off Passengers

Passengers come to and leave from doors by their own will. The truck stops by a door (+) if you are carrying at least one passenger. Bump such a door to drop off a passenger and restore 8 turns.

The truck stops by an awaiting passenger (P) if you have at least one unoccupied slot. Bump a passenger to pick him up and restore 4 turns. You cannot drop off a passenger who has just got on the truck. You can tell this by his opaque face. The face turns to transparent once you start driving.
