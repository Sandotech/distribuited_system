# frozen_string_literal: true

require 'logger'
require_relative 'time_generator'

# Node class that communicates with oher nodes, save state, and choose a leader node
class Node
  attr_reader :id, :neighbors, :log, :current_term, :voted_for, :role, :timer
  attr_accessor :state, :statuses, :vote_count

  def initialize(id)
    @id = id
    @neighbors = []
    @log = []
    @state = []
    @current_term = 0
    @voted_for = nil
    @timer = RandomTimeGenerator.random_time
    @role = :follower
    @vote_count = 0
    @statuses = Array.new(3, :active) # This depends on the needs
    @logger = Logger.new($stdout)
    log_action("Node #{@id} initialized")
  end

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

  # Simulate election process
  def start_election
    become_candidate
    request_votes
  end

  def become_follower
    @role = :follower
    log_action("Node #{@id} became follower")
  end

  # Handle vote reception
  def receive_vote(vote)
    return unless @role == :candidate

    log_action("Node #{@id} received vote from Node #{vote[:from]} for term #{vote[:term]}")

    return unless vote[:term] == @current_term && vote[:granted]

    @vote_count += 1
    become_leader if @vote_count > (@neighbors.size / 2)
  end

  # Collect timers from neighbors and self
  def all_timers
    @neighbors.map(&:timer) + [@timer]
  end

  # Request votes from neighbors
  def request_votes
    @neighbors.each { |neighbor| neighbor.receive_vote_request(term: @current_term, from: @id) }
  end

  def receive_vote_request(request)
    return unless request[:term] >= @current_term

    log_action("Node #{@id} received vote request from Node #{request[:from]} for term #{request[:term]}")

    if request[:term] > @current_term
      @current_term = request[:term]
      become_follower
    end

    grant_vote = !@voted_for && request[:term] == @current_term
    @voted_for = request[:from] if grant_vote
    send_vote_response(request[:from], grant_vote)
  end

  # Check if current node is leader
  def leader?
    @role == :leader
  end

  # Check if any neighbor is the leader
  def any_neighbor_is_leader?
    @neighbors.any?(&:leader?)
  end

  # Propose new state
  def propose_state(new_state)
    if !there_is_leader?
      log_action("Node #{@id} is proposing state #{new_state}")
      @state << new_state
      @neighbors.each { |neighbor| neighbor.state = new_state }
      become_leader
    else
      log_action("Node #{@id} cannot propose state #{new_state} because a leader exists")
    end
  end

  def send_proposal_to_leader(new_state)
    leader = @neighbors.find(&:leader?)

    if leader
      log_action("Node #{@id} is sending state proposal #{new_state} to Leader Node #{leader.id}")
      leader.collect_proposal(@id, new_state)
    else
      log_action('No leader available for proposal')
    end
  end

  # Leader collects proposals
  def collect_proposal(follower_id, proposed_state)
    return unless leader?

    log_action("Leader Node #{@id} received state proposal #{proposed_state} from Node #{follower_id}")
    @state << proposed_state
    @neighbors.each { |neighbor| neighbor.state = proposed_state }
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
  
  # Check if node is active
  def active?
    @statuses[@id - 1] == :active
  end

  def become_candidate
    return if there_is_leader?

    @role = :candidate
    @current_term += 1
    @voted_for = nil
    log_action("Node #{@id} became candidate for term #{@current_term}")
    request_votes
  end

  def become_leader
    @role = :leader
    log_action("Node #{@id} became leader for term #{@current_term}")
    update_follower_statuses
  end

  def update_follower_statuses
    @neighbors.each { |neighbor| neighbor.statuses[@id - 1] = :leader }
  end

  # Send vote response
  def send_vote_response(candidate_id, granted)
    log_action("Node #{@id} sending vote response to Node #{candidate_id}: #{granted}")
    neighbor = @neighbors.find { |n| n.id == candidate_id }
    neighbor&.receive_vote(term: @current_term, from: @id, granted: granted)
  end

  # Log any action
  def log_action(action)
    @log.push(action)
    @logger.info(action)
  end

  # Retrieve log for analysis
  def retrieve_log
    @log.join("\n")
  end

  def there_is_leader?
    leader? || any_neighbor_is_leader?
  end
end

# Example Usage
node1 = Node.new(1)
node2 = Node.new(2)
node3 = Node.new(3)

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

puts "Node 1 Log:\n#{node1.retrieve_log}"
puts "Node 2 Log:\n#{node2.retrieve_log}"
puts "Node 3 Log:\n#{node3.retrieve_log}"

puts "Node 1 Status: #{node1.statuses.inspect}"
puts "Node 2 Status: #{node2.statuses.inspect}"
puts "Node 3 Status: #{node3.statuses.inspect}"

puts "Node 1 Role: #{node1.role}"
puts "Node 2 Role: #{node2.role}"
puts "Node 3 Role: #{node3.role}"

puts node1.state
puts node2.state
puts node3.state
