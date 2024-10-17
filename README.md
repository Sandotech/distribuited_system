# Consensus Protocol Implementation

This project implements a simplified version of a consensus protocol using Ruby. The primary focus is on how nodes communicate, propose states, and elect a leader in a distributed system.

## Overview

The implementation consists of two main classes:

1. **`RandomTimeGenerator`**: Generates random time intervals to simulate delays in message sending.
2. **`Node`**: Represents a node in the distributed system, capable of sending messages, handling state proposals, managing neighbor nodes, and participating in elections.

## Classes

### RandomTimeGenerator

This class provides a method to generate a random time in milliseconds.

#### Methods

- **`self.random_time(min_ms = 1, max_ms = 1000)`**
  - Generates a random time between the specified minimum and maximum milliseconds.
  - Raises an `ArgumentError` if the minimum time is not less than the maximum.

### Node

The `Node` class simulates a node in a distributed system and handles its state, message processing, and neighbor communication.

#### Attributes

- `id`: The unique identifier for the node.
- `neighbors`: An array of neighboring nodes for communication.
- `log`: An array to keep track of log messages.
- `state`: The current state of the node.
- `current_term`: The current term of the node during the election process.
- `voted_for`: The ID of the node that this node has voted for in the current term.
- `role`: The current role of the node (follower, candidate, or leader).
- `timer`: A random timer generated at node initialization.
- `status`: The status of the node (active or inactive).

#### Methods

- **`initialize(id)`**
  - Initializes a new node with the specified ID and sets up its attributes.

- **`add_neighbor(node)`**
  - Adds a neighboring node for communication.

- **`send_message(message, recipient)`**
  - Sends a message to a neighboring node if it is active.

- **`receive_message(message, sender)`**
  - Processes incoming messages based on their type.

- **`process_message(message)`**
  - Determines the type of message and calls the appropriate handler.

- **`handle_state_proposal(message)`**
  - Processes a state proposal message and validates it.

- **`handle_vote_request(message)`**
  - Handles incoming vote requests from other nodes.

- **`handle_vote_response(message)`**
  - Processes incoming vote responses.

- **`start_election`**
  - Initiates the election process for the node.

- **`become_candidate`**
  - Changes the node's role to candidate and requests votes.

- **`become_leader`**
  - Changes the node's role to leader.

- **`propose_state(new_state)`**
  - Proposes a new state if there is no existing leader.

- **`simulate_partition(partitioned_nodes)`**
  - Simulates a network partition by disconnecting from specified neighbor nodes.

- **`resolve_partition(partitioned_nodes)`**
  - Reconnects with previously partitioned nodes.

- **`retrieve_log`**
  - Returns the log messages as a string.

## Example Usage

The following code demonstrates how to create nodes, add neighbors, and simulate consensus proposals.

```ruby
# Create nodes
node1 = Node.new(1)
node2 = Node.new(2)
node3 = Node.new(3)

# Add neighbors
node1.add_neighbor(node2)
node1.add_neighbor(node3)
node2.add_neighbor(node1)
node2.add_neighbor(node3)
node3.add_neighbor(node1)
node3.add_neighbor(node2)

# Simulate consensus proposals
node1.propose_state(1)
node2.propose_state(2)

# Simulate a partition
node3.simulate_partition([node1])

# Node2 proposes a new state while node1 is partitioned
node2.propose_state(3)

# Check logs
puts "Node 1 Log:\n" + node1.retrieve_log
puts "Node 2 Log:\n" + node2.retrieve_log
puts "Node 3 Log:\n" + node3.retrieve_log
