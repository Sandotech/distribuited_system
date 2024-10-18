<div align="center">
  <a href="https://www.linkedin.com/in/sandotech" target="_blank">
    <img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white">
  </a>&nbsp;&nbsp;
  <a href="#top">
    <img src="https://img.shields.io/badge/Ruby-CC342D?style=for-the-badge&logo=ruby&logoColor=white" alt="Ruby">
  </a>&nbsp;&nbsp;
  <a href="https://www.github.com/Sandotech" target="_blank">
    <img src="https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white" />
  </a>
</div>

# Distributed Consensus Simulation

This project simulates a simplified version of a distributed consensus algorithm, inspired by the Raft consensus protocol. It demonstrates basic concepts of leader election, state proposals, and network partitions in a distributed system.

## Overview

The simulation consists of a `Node` class that represents individual nodes in a distributed system. These nodes can communicate with each other, elect a leader, propose and agree on states, and handle network partitions. Logs of node actions can be retrieved in a structured format for analysis.

![image](https://github.com/user-attachments/assets/bf81a028-0453-419c-a553-86bf16d7decb)

## Features

- Leader election
- State proposal and agreement
- Network partition simulation
- Structured logs for each node
- Customizable logging levels for cleaner output

## Requirements

- Ruby (version 2.5 or higher recommended)
- Bundle to handle configuration

## Usage

1. Install the bundle:
   ```sh
   bundle install
   ```

2. Run the simulation:
   ```sh
   ruby main.rb
   ```

3. Run the tests (optional but recommended):
   ```sh
   bundle exec rspec --format documentation
   ```

## Node Class

The `Node` class simulates the behavior of a node in a distributed consensus system. Each node maintains a log of actions and communicates with other nodes to elect a leader and propose states.

### Properties

| Property       | Description                                       |
|----------------|---------------------------------------------------|
| `id`           | Unique identifier for the node                    |
| `neighbors`    | List of neighboring nodes                         |
| `log`          | Action log of the node                            |
| `state`        | Current state of the node                         |
| `current_term` | Current term in the election process              |
| `role`         | Current role (follower, candidate, or leader)     |
| `timer`        | Random timer for election timeout                 |

### Node Class Methods 🚀

- **`initialize(id)`**: Creates a new node with the given ID.
- **`add_neighbor(node)`**: Adds a neighboring node 🔗
- **`send_message(message, recipient)`**: Sends a message to another node.
- **`receive_message(message, sender)`**: Receives a message from another node.
- **`start_election()`**: Initiates an election process.
- **`propose_state(new_state)`**: Proposes a new state.
- **`simulate_partition(partitioned_nodes)`**: Simulates a network partition.

## Key Updates

1. **Logging Level Control**: The logging mechanism has been updated to allow control over log levels. By default, only warning and higher levels (such as errors) will be printed to the console. This reduces noise from `INFO` level logs during normal execution. To change the logging level, modify the `@logger.level` in the `Node` class.
    ```ruby
    @logger.level = Logger::WARN  # Only warnings and errors are shown
    ```
   
2. **Log Structure**: Each node maintains an internal log of its actions that can be retrieved and printed in a structured format. This helps in understanding the sequence of events and the decision-making process of each node.

3. **Enhanced Network Partition Handling**: The `simulate_partition` method allows more flexible simulation of network failures between nodes. This feature can be used to explore the behavior of the system in various failure scenarios.

## Simulation Process

1. Nodes are created and connected as neighbors.
2. A node proposes a state, triggering leader election if no leader exists.
3. Network partitions can be simulated, causing nodes to become disconnected.
4. Nodes continue to propose states and handle leadership changes.
5. Logs for each node are printed after the simulation for detailed analysis.

## Example

```ruby
# /distributed_system/main.rb

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

## Sample Output

```
+----------------------------------------+
|               Node 1 Log               |
+------+---------------------------------+
| Step | Log Entry                       |
+------+---------------------------------+
| 1    | Node 1 initialized              |
| 2    | Node 1 added neighbor Node 2    |
| 3    | Node 1 added neighbor Node 3    |
| 4    | Node 1 is proposing state 1     |
| 5    | Node 1 became leader for term 0 |
| 6    | Node 1 became follower          |
+------+---------------------------------+

+--------------------------------------------------------------+
|                          Node 2 Log                          |
+------+-------------------------------------------------------+
| Step | Log Entry                                             |
+------+-------------------------------------------------------+
| 1    | Node 2 initialized                                    |
| 2    | Node 2 added neighbor Node 1                          |
| 3    | Node 2 added neighbor Node 3                          |
| 4    | Node 2 received vote request from Node 3 for term 1   |
| 5    | Node 2 became follower                                |
| 6    | Node 2 sending vote response to Node 3: true          |
| 7    | Node 2 received vote request from Node 3 for term 1   |
| 8    | Node 2 sending vote response to Node 3: false         |
| 9    | Node 2 cannot propose state 3 because a leader exists |
+------+-------------------------------------------------------+

+-----------------------------------------------------+
|                     Node 3 Log                      |
+------+----------------------------------------------+
| Step | Log Entry                                    |
+------+----------------------------------------------+
| 1    | Node 3 initialized                           |
| 2    | Node 3 added neighbor Node 1                 |
| 3    | Node 3 added neighbor Node 2                 |
| 4    | Node 3 simulating partition from Node 1      |
| 5    | Node 3 can no longer communicate with Node 1 |
| 6    | Node 3 became candidate for term 1           |
| 7    | Node 3 received vote from Node 2 for term 1  |
| 8    | Node 3 became leader for term 1              |
+------+----------------------------------------------+
```

<footer align="center">
  Diego Santos
<br/>
  Backend Developer
</footer>

<h3 align="center">Thanks for being here</h3>

--- 
