# Mirror X Mirror

[INPUT_HINT]

## Win and Lose

The dungeon is divided into two parts, the real world and the mirror world. To beat the game, you need to let a phantom image in the mirror world collect five crystals (*). You lose the game either due to running out of turns or you can no longer collect crystals.

## Mirrors

There is a long wall of mirrors (#) that splits the map. You will also encounter short walls of mirrors in the dungeon. A wall of mirrors blocks movement. It has two faces and creates a reflection under certain circumstances. More on this below.

    ##  Facing up and down

    #   Facing left and right
    #

## Move Around

A phantom (p) in the real world moves towards PC (@) when he is nearby. A phantom's image (p, grey) in the mirror world never moves.

When PC moves in the real world, his image (@, grey) in the mirror world also moves symmetrically. If PC or his image is blocked by a mirror, neither of them can move. See *Bump or Push a Target*.

Moving 1 step, bumping or pushing costs 1 turn. Press Space to wait 1 turn.

## Bump or Push a Target

When a phantom in the real world bumps adjacent PC, the real world swaps with the mirror world.

When PC bumps a phantom in the real world, four things happen. Firstly, the phantom disappears. Secondly, the phantom's image appears in the mirror world. Thirdly, one or more phantoms might appear in the real world as mirror reflections. And lastly, the countdown timer restores 3 or 6 turns.

* Restore 3 turns: You only create an image in the mirror world.
* Restore 6 turns: You create an image and at least one new phantom.

There can be at most `5 - CRYSTAL` phantom images in the mirror world. Random extra images are removed whenever a new image is created.

When PC's image bumps a phantom's image in the mirror world, if the phantom image is not blocked by a mirror, another image or an edge of the dungeon, the image is pushed by 1 grid, and PC and his image moves 1 step as well.

When both PC and his image bumps a phantom and another phantom's image, you can pretend that three things happen in turn, even though the game does not work like this behind the scene. Phantom A disappears and you restore turns. Phantom B's image disappears. Phantom A's image appears.

## Collect a Crystal

In the real world, a crystal dose not block movement. When PC or a phantom stands on a crystal, their symbol turns into a rectangle.

A phantom image (but not PC's image) in the mirror world can collect a crystal by standing on it. There are three ways to collect a crystal.

* The most direct way is to push a phantom image to cover a crystal.
* Or, hit a phantom and let its image appear over a crystal.
* You can also let a phantom stands on a crystal, and swap two worlds in the next turn.

A new crystal appears in a random position after the previous one is collected.

If in the real world, there are only PC and a crystal but no phantoms, you can never collect any more crystals. This results in an instant death. There is another very rare checkmate pattern. You lose the game if your image is surrounded by mirrors, one or more edges of the dungeon, and/or immovable phantom images, and no phantoms in the real world can see you.
