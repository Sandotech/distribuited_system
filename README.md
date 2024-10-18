<div align="center">
  <a href="https://www.linkedin.com/in/sandotech" target="_blank">
    <img src="  https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white">
  </a>&nbsp;&nbsp;
  <img src="https://img.shields.io/badge/Ruby-CC342D?style=for-the-badge&logo=ruby&logoColor=white" alt="Ruby">&nbsp;&nbsp;
  <a href="https://www.github.com/Sandotech" target="_blank">
  <img src="https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white">
  </a>
</div>

# Distributed Consensus Simulation

This project simulates a simplified version of a distributed consensus algorithm, inspired by the Raft consensus protocol. It demonstrates basic concepts of leader election, state proposals, and network partitions in a distributed system.

## Overview

The simulation consists of a `Node` class that represents individual nodes in a distributed system. These nodes can communicate with each other, elect a leader, propose and agree on states, and handle network partitions.

![image](https://github.com/user-attachments/assets/bf81a028-0453-419c-a553-86bf16d7decb)

## Features

- Leader election
- State proposal and agreement
- Network partition simulation
- Basic logging of node actions

## Requirements

- Ruby (version 2.5 or higher recommended)
- Bundle to handle configuration

## Usage

1- Install the bundle:
  ```sh
  bundle install
  ```
2- Run the simulation:
   ```sh
   ruby main.rb
   ```
3- Run the tests (optional but recommended)
  ```sh
   bundle exec rspec --format documentation
  ```

## Class: Node

<div align="center">

| Property       | Description                                       |
|----------------|---------------------------------------------------|
| `id`           | Unique identifier for the node                    |
| `neighbors`    | List of neighboring nodes                         |
| `log`          | Action log of the node                            |
| `state`        | Current state of the node                         |
| `current_term` | Current term in the election process              |
| `role`         | Current role (follower, candidate, or leader)     |
| `timer`        | Random timer for election timeout                 |
</div>

### Node Class Methods 🚀

- **`initialize(id)`**: Creates a new node with the given ID.
- **`add_neighbor(node)`**: Adds a neighboring node 🔗
- **`send_message(message, recipient)`**: Sends a message to another node.
- **`receive_message(message, sender)`**: Receives a message from another node.
- **`start_election()`**: Initiates an election process.
- **`propose_state(new_state)`**: Proposes a new state.
- **`simulate_partition(partitioned_nodes)`**: Simulates a network partition.

## Simulation Process

1. Nodes are created and connected as neighbors.
2. A node proposes a state, triggering leader election if no leader exists.
3. Network partitions can be simulated, causing nodes to become disconnected.
4. Nodes continue to propose states and handle leadership changes.

## Example

```ruby
node1 = Node.new(1)
node2 = Node.new(2)
node3 = Node.new(3)

# Connect nodes
node1.add_neighbor(node2)
node1.add_neighbor(node3)
node2.add_neighbor(node1)
node2.add_neighbor(node3)
node3.add_neighbor(node1)
node3.add_neighbor(node2)

# Simulate state proposals and partitions
node1.propose_state(1)
node3.simulate_partition([node1])
node2.propose_state(3)

# Display results
puts "Node 1 Log:\n#{node1.retrieve_log}"
puts "Node 2 Log:\n#{node2.retrieve_log}"
puts "Node 3 Log:\n#{node3.retrieve_log}"
```

### Thanks for be here

<footer>
  Diego Santos
<br/>
  Backend Developer
</footer>
