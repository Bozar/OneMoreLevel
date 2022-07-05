# The Baron in the Trees

[INPUT_HINT]

> So began their love, the boy happy and amazed, she happy and not surprised at all (nothing happens by chance to girls).
>
> -- The Baron in the Trees, Chapter 17

There are 5 bandits lurking in the woods. In order to protect his village, the baron in the trees needs to find out at least 2 of them in 24 turns.

## Ground Layer and Canopy Layer

The dungeon map has two layers: ground layer and canopy layer. Bandits walk on the ground. The baron and birds stay in the canopy. Trees are rooted in the ground and stretch themselves into the higher layer.

An unoccupied and uncovered ground grid is shown as a minus sign (-). An unoccupied ground grid that is covered by a tree branch is shown as a plus sign (+). A ground grid that is occupied by a tree trunk is shown as an uppercase O. A marked tree trunk (see *Search Bandits*) is shown as an exclamation mark (!).

## Bandits and Birds

The whole dungeon is divided equally into nine zones, five of them each contains a bandit at the start of the game. A bandit then repeats the following behavior pattern until he is removed from the game (see *Search Bandits*).

* Select a reachable destination.
* Follow the shortest path towards the destination.
* Once reaching the destination, select a new one.

A bandit is shown as a digit which equals to his remaining hit points (see *Search Bandits*). He cannot leave the ground, nor can he walk past a tree trunk or another bandit. He is visible to PC if he is in PC's sight (see *Search Bandits*) and is not covered by a tree branch.

A bird either rests on a tree branch or a tree trunk, or flies in the sky. A flying bird is invisible to PC, otherwise it is always visible. A bird is shown as one of the two letters.

* x: The bird stands on two legs on a trunk.
* y: The bird stands on one leg on a branch.

When a bandit is within 3 grids from a bird, the bird has an 80% chance to fly away. PC can drive away a bird by walking into the grid it occupies. A bird has a 10% chance to leave even when undisturbed.

## Move in the Trees

PC can only move in grids that are either tree trunks or tree branches. When standing on a branch, he is shown as three dashes. When standing on an unmarked trunk, he is shown as an "at" symbol (@), or double exclamation marks (!!) when on a marked trunk.

Press arrow keys to move one step. When standing on a tree trunk (whether marked or unmarked), press Space to wait. Both actions cost 1 turn.

## Search Bandits

Initially, PC can see a bandits who is 3 grids away. After finding out the first bandit, it begins to rain and PC's sight range reduces to 2 grids. PC's line of sight is blocked by tree trunks, but nothing else.

When PC's turn starts, if he can see only one bandit, the bandit loses 1 hit point when PC's current turn ends. This results in two possible situations.

If the bandit has one or more hit points left, PC restores 1 turn.

If the bandit has no hit points left, PC restores 10 turns. The bandit is removed from the game forever. A random tree trunk turns from a letter O to an exclamation mark. It means that PC has fully revealed the bandit's secrets and has found out a point of interest. The marked trunk acts as an indicator of the number of bandits you have discovered. It behaves the same as an unmarked one in other aspects.

A bandit has 9 hit points. PC has at most 24 turns. As mentioned above, PC needs to reveal at least 2 of the 5 bandits to beat the game. When the last turn ends and PC has only found zero or one bandit, he loses.

If there are two or more bandits in PC's sight at the start of his turn, select one of them and reduces his hit point by 1 according to two rules.

* Choose the bandit with the lowest hit point.
* If there are more than one candidates, pick one randomly.
