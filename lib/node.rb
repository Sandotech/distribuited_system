class Node
  attr_reader :id, :log, :neighbors, :state, :proposed_state

  def initialize(id)
    @id = id
    @neighbors = []
    @log = []
    @state = nil
    @proposed_state = nil
    @partitioned = false
    @active = true
  end

  # Add neighbor nodes for communication
  def add_neighbor(node)
    @neighbors << node unless @neighbors.include?(node)
  end

  # Propose a new state
  def propose_state(new_state)
    return unless @active
    
    log_message("Node #{@id} proposing state #{new_state}")
    @proposed_state = new_state
    
    send_message_to_neighbors(new_state)
    # Reach consensus
    reach_consensus
  end

  # Simulate network partition
  def simulate_partition(nodes_to_partition)
    @partitioned = nodes_to_partition.include?(self)
    log_message("Node #{@id} is partitioned") if @partitioned
  end

  # Simulate node failure
  def simulate_failure
    @active = false
    log_message("Node #{@id} has failed")
  end

  # Receive a proposed state from another node (make this method public)
  def receive_message(sender_id, state)
    return unless @active && !@partitioned

    log_message("Node #{@id} received state #{state} from Node #{sender_id}")
    # Compare and keep the highest proposed state
    if @proposed_state.nil? || state > @proposed_state
      @proposed_state = state
      log_message("Node #{@id} updating proposed state to #{state}")
    end
  end

  # Retrieve log for analysis
  def retrieve_log
    @log.join("\n")
  end

  # Public method to check if the node is active
  def active?
    @active
  end

  private

  # Send message to neighbors, unless partitioned
  def send_message_to_neighbors(new_state)
    return if @partitioned

    @neighbors.each do |neighbor|
      if neighbor.active?
        log_message("Node #{@id} sends proposed state #{new_state} to Node #{neighbor.id}")
        neighbor.receive_message(@id, new_state)
      end
    end
  end

  # Reach consensus by selecting the highest proposed state
  def reach_consensus
    if @proposed_state
      @state = @proposed_state
      log_message("Node #{@id} reached consensus with state #{@state}")
    end
  end

  # Log state transitions and messages
  def log_message(message)
    @log << message
  end
end

# Test Simulation

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

# Propose states
node1.propose_state(1)
node2.propose_state(2)

# Simulate partition where node1 is isolated
node3.simulate_partition([node1])

# Node2 proposes a higher state
node2.propose_state(3)

# Retrieve logs
puts "Node 1 Log:\n" + node1.retrieve_log
puts "Node 2 Log:\n" + node2.retrieve_log
puts "Node 3 Log:\n" + node3.retrieve_log
