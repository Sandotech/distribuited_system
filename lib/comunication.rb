# frozen_string_literal: true

# Module for communication between nodes
module Communication
  # Add neighbor node for communication
  def add_neighbor(node)
    @neighbors << node unless @neighbors.include?(node)
    log_action("Node #{@id} added neighbor Node #{node.id}")
  end

  # Send message to recipient
  def send_message(message, recipient)
    if @neighbors.include?(recipient) && recipient.active?
      recipient.receive_message(message, self)
      log_action("Node #{@id} sent message: '#{message}' to Node #{recipient.id}")
    else
      log_action("Node #{@id} failed to send message to Node #{recipient.id} (inactive or not a neighbor)")
    end
  end

  # Receive and process a message
  def receive_message(message, sender)
    log_action("Node #{@id} received message: '#{message}' from Node #{sender.id}")
    process_message(message)
  end

  # Simulate partitioning of nodes
  def simulate_partition(partitioned_nodes)
    log_action("Node #{@id} simulating partition from Nodes #{partitioned_nodes.map(&:id).join(', ')}")
    become_follower if leader?

    partitioned_nodes.each do |node|
      next unless @neighbors.include?(node)

      @neighbors.delete(node)
      node.statuses[@id - 1] = :died
      node.become_follower
      log_action("Node #{@id} can no longer communicate with Node #{node.id}")
    end

    start_election
  end
end
