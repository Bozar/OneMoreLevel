# A Roadside Picnic in an Abandoned Factory

[INPUT_HINT]

> Stalkers report running into concrete objects in the Zone. They are one head taller than an average man and they move swiftly and quietly. It seems that they enjoy chasing and cornering human beings, but no real harm has been done. Every object has a spray painted number on its chest. All of them are primes. The greatest known prime is 173.

You need to find 3 rare gadgets (!) in an abandonded factory. However, the factory is a weird place. Your courage only lasts 24 turns. You lose the game if you run out of time.

## The Factory

A factory building consists of walls (#) and doors (+). A wall blocks movement and line of sight. A door blocks line of sight, but it does not prevent moving. An indoor floor (long dash) looks different from an outdoor floor (short dash) for aesthetic reasons. There is an arrow that indicates the number of rare gadgets you have collected so far.

* Down arrow: 0 gadget.
* Left arrow: 1 gadget.
* Up arrow: 2 gadgets.
* Right arrow: 3 gadgets.

You can think of the arrow as an hour hand. You enter the factory at 6 a.m. It takes 3 hours to find a rare gadget. If everything goes smoothly, you leave the place at 3 p.m.

Press arrow keys to move around. Press Space to wait. An action (move or wait) costs 1 turn. You have at most 24 turns. The game ends if there is no turn left.

## Common and Rare Gadgets

There are two types of gadgets: common (?) and rare (!). If you move over a rare gadget, you collect it automatically and your remaining time restores to its maximum: 24 turns. If you move over a common gadget, you put it into your bag. Your symbol, which is a digit, shows how many common gadgets you have found. Your bag holds at most 9 of them. A common gadget disappears if you walk past it with a full bag.

As mentioned above, you need to collect 3 rare gadgets to beat the game. At least one of them is far away from your starting point. And they are not so close to each other. Besides, there are 3 fake rare gadgets which look the same as a real one but have no effect when picking up. Fake gadgets do not need to be far away from each other or PC's starting point.

When pressing Space to wait, if you have no common gadgets in the bag, you lose 1 turn. Otherwise, you lose 1 gadget and restore 5 turns, which can be interpreted as you identify an unknown gadget and regain courage.

You cannot move if there is only one turn left and you have at least one common gadget. The game forces you to press Space to restore turns. On the other hand, you can move and collect a rare gadget on the last turn. You do not need to remember these two rules. They take effect when necessary to prevent you from making careless mistakes.

## Concrete Objects

Concrete objects (C) lurk in the factory. At the start of your turn, every object in your sight is awakened and every grids you can see is marked as visible. An awakened object approaches you by at most 2 grids for 1 turn. It stops moving once being adjacent to you. If an object has not been seen by you for a few consecutive turns, it teleports to a random place. You cannot tell how far away, but it does not enter a visible grid.

You can see at most 5 grids. You cannot walk past or attack a concrete object, nor do they attack you. Press Space to wait if you are cornered. All adjacent objects will teleport away the next turn.
