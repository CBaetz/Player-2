# Player-2
Attempted development of a neural network to play a simple game
Java in Processing.

The game itself is a simplified version of the Royal Game of Ur, which plays a lot like Frustration.
In this simplified game, the goal is to get all 7 pieces across the board.
The board is 8 spaces long, and landing on top of another player's piece sends them to the start.
You cannot land on a space with your own token on it.
The rolling system is from 0 to 4, with 4 coin flips of either 0 or 1 added up.

V1 is a base version where the User has control of 1 player by clicking on the piece they would like to move.
This version also requires a click for the AI (just a simple neural network) to make its move.

V2 plays 2 AI players against each other forever

V3 plays 2 AI players against each other a set amount of times to see which is better.

V4 plays 2 AI players against each other a set amount of times when given a click, to see which player is better.
It then saves the updated version of the AI.

V5 plays 2 AI players against each other automatically and updates the AI.
