# **Gossip Protocol Simulator | Distributed Systems**

## **Highlights**
- Implemented gossip protocol and push-sum algorithm over a network of 1M nodes and simulated for six topologies

## **Objective**
### **Gossip Protocol**

Gossip algorithms can be used both for group communication and for aggregate computation. The goal of this project is to determine the convergence of such algorithms through a simulator based on actors written in Elixir. Since actors in Elixir are fully asynchronous, the particular type of Gossip implemented is the so-called Asynchronous Gossip.

The Gossip algorithm involves the following:
- Starting: A participant(actor) it told/sent a rumor(fact) by the main process
- Step: Each actor selects a random neighbor and tells it the rumor
- Termination: Each actor keeps track of rumors and how many times it has
heard the rumor. It stops transmitting once it has heard the rumor 10 times
(10 is arbitrary, you can play with other numbers or other stopping criteria).

Apart from Gossip, I also implemented the push-sum algorithm for sum computation.
The Push-sum algorithm involves the following:
- State: Each actor Ai maintains two quantities: s and w. Initially, s = xi = i (that
is actor number i has value i, play with other distribution if you so desire) and
w = 1.
- Starting: Ask one of the actors to start from the main process.
- Receive: Messages sent and received are pairs of the form (s, w). Upon
receive, an actor should add received pair to its own corresponding values.
Upon receive, each actor selects a random neighbor and sends it a message.
- Send: When sending a message to another actor, half of s and w is kept by
the sending actor and half is placed in the message.
- Sum estimate: At any given moment of time, the sum estimate is s/w where
s and w are the current values of an actor.
- Termination: If an actor ratio s/w did not change more than 10-10 in 3
consecutive rounds the actor terminates. WARNING: the values s and w
independently never converge, only the ratio does.

### **Handling Failure**
When a node dies, a connection dies temporarily or permanently, failure occurs in the system. Different topologies cope up with failures differently. I measured the failure handling capability of different topogies and proposed a mechanism of replacing the failure node with an random node to greatly improve the performance and keeping the algorithm simple.

### **Network Topologies**

The actual network topology plays a critical role in the dissemination
speed of Gossip protocols. We handled the following network topologies and tested the convergence time for each of them. The topology determines who is considered a neighbor in the
above algorithms.

1. Full Network: Every actor is a neighbor of all other actors. That is, every actor
can talk directly to any other actor.
2. Line: Actors are arranged in a line. Each actor has only 2 neighbors (one left
and one right, unless you are the first or last actor).
3. Random 2D Grid: Actors are randomly position at x, y coordinates on a [0-
1.0] x [0-1.0] square. Two actors are connected if they are within .1 distance
to other actors.
4. 3D torus Grid: Actors form a 3D grid. The actors can only talk to the grid
neighbors. And, the actors on outer surface are conne
5. Honeycomb: Actors are arranged in form of hexagons. Two actors are
connected if they are connected to each other. Each actor has maximum
degree 3.
6. Honeycomb with a random neighbor: Actors are arranged in form of
hexagons (Similar to Honeycomb). The only difference is that every node has
one extra connection to a random node in the entire network.


##  **Tech Stack**
Elixir Actor modeling: the actor facility using GenServer in Elixir is used for this simulation.

## **Steps to run code**
1. Open Terminal
2. cd project_folder/app
3. Generate executable with `mix escript.build`
4. Run with `escript ./app numNodes topology algorithm` where
numNodes is the number of actors involved
topology is one of `full/line/rand2D/3Dtorus/honeycomb/randhoneycomb`
algorithm is one of `gossip/push-sum`



## **Result**

Gossip and Push-Sum algorithms are simulated succesfully for all the above topologies with varying convergence times due to the inherent nature of said topologies, which govern the spread of messages. An instance would be where Line topolgy has consistenetly the highest time to converge values while Random Honeycomb or 3D Torus fair far better.


### Gossip Protocol-

| Topology    | Network Size     | Convergence time (ms)|
| ----------- | -----------      | ---------------------|
| Full Network | 10000| 123859|
| Line | 2500|193063|
| Random 2D Grid | 7000|11828|
| 3D Torus Grid | 25000|50453|
| Honeycomb | 25000|208609|
| Random Honeycomb | 150000|17658|

### Push Sum Algorithm-

| Topology    | Network Size     |Convergence time (ms)|
| ----------- | -----------      |---------------------|
| Full Network | 1500|73563|
| Line | 400|666281|
| Random 2D Grid | 3000|99172|
| 3D Torus Grid | 1500|86391|
| Honeycomb | 1500|311297|
| Random Honeycomb | 150000|237671|
