# frozen_string_literal: true

require 'logger'
require_relative 'time_generator'
require_relative 'election'
require_relative 'comunication'

# Node class that communicates with other nodes, saves state, and chooses a leader node
class Node
  include Election
  include Communication

  attr_reader :id, :neighbors, :log, :current_term, :voted_for, :role, :timer
  attr_accessor :state, :statuses, :vote_count

  def initialize(id)
    @id = id
    initialize_neighbors
    initialize_state
    initialize_election_params
    initialize_logger
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

  # Check if node is active
  def active?
    @statuses[@id - 1] == :active
  end

  def become_follower
    @role = :follower
    log_action("Node #{@id} became follower")
  end

  def update_follower_statuses
    @neighbors.each { |neighbor| neighbor.statuses[@id - 1] = :leader }
  end

  # Retrieve log for analysis
  def retrieve_log
    @log.join("\n")
  end

  private

  def initialize_neighbors
    @neighbors = []
  end

  def initialize_state
    @state = []
    @statuses = Array.new(3, :active)
  end

  def initialize_election_params
    @current_term = 0
    @voted_for = nil
    @timer = RandomTimeGenerator.random_time
    @role = :follower
    @vote_count = 0
  end

  # Log any action
  def log_action(message)
    @log << message
    @logger.info(message)
  end

  def initialize_logger
    @log = []
    @logger = Logger.new($stdout)
    @logger.level = Logger::WARN # This is to debug purposes
    log_action("Node #{@id} initialized")
  end
end
