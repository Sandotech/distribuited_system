# spec/node_spec.rb

require_relative '../lib/node'
require 'rspec'
require 'logger'

RSpec.describe Node do
  let(:node1) { Node.new(1) }
  let(:node2) { Node.new(2) }
  let(:node3) { Node.new(3) }

  before do
    # Disable logger output in the test for cleaner output
    allow_any_instance_of(Logger).to receive(:info)
  end

  describe '#initialize' do
    it 'initializes a node with the correct attributes' do
      expect(node1.id).to eq(1)
      expect(node1.neighbors).to eq([])
      expect(node1.state).to eq([])
      expect(node1.role).to eq(:follower)
      expect(node1.current_term).to eq(0)
      expect(node1.vote_count).to eq(0)
      expect(node1.statuses).to eq([:active, :active, :active])
    end
  end

  describe '#add_neighbor' do
    it 'adds a neighbor to the node' do
      node1.add_neighbor(node2)
      expect(node1.neighbors).to include(node2)
      expect(node1.log).to include("Node 1 added neighbor Node 2")
    end
  end

  describe '#send_message' do
    context 'when the neighbor is inactive' do
      it 'fails to send the message' do
        node1.add_neighbor(node2)
        node2.statuses[1] = :died
        node1.send_message('Hello', node2)
        expect(node1.log).to include("Node 1 failed to send message to Node 2 (inactive or not a neighbor)")
      end
    end
  end

  describe '#start_election' do
    it 'transitions to candidate and requests votes' do
      node1.add_neighbor(node2)
      node1.start_election
      expect(node1.role).to eq(:candidate)
      expect(node1.log).to include("Node 1 became candidate for term 1")
    end
  end

  describe '#receive_vote' do
    context 'when the node is a candidate' do
      it 'receives votes and becomes leader if majority is reached' do
        node1.add_neighbor(node2)
        node1.add_neighbor(node3)
        node2.add_neighbor(node1)
        node3.add_neighbor(node1)

        node1.become_candidate

        node1.receive_vote(term: 1, from: node2.id, granted: true)
        node1.receive_vote(term: 1, from: node3.id, granted: true)

        expect(node1.vote_count).to eq(2)
        expect(node1.role).to eq(:leader)
        expect(node1.log).to include("Node 1 became leader for term 1")
      end
    end
  end

  describe '#propose_state' do
    context 'when there is no leader' do
      it 'proposes new state and becomes leader' do
        node1.add_neighbor(node2)
        node1.propose_state(100)
        expect(node1.state).to include(100)
        expect(node1.role).to eq(:leader)
        expect(node1.log).to include("Node 1 is proposing state 100")
      end
    end

    context 'when there is a leader' do
      it 'does not propose a new state' do
        node1.add_neighbor(node2)
        node2.become_leader
        node1.propose_state(100)
        expect(node1.state).to_not include(100)
        expect(node1.log).to include("Node 1 cannot propose state 100 because a leader exists")
      end
    end
  end

  describe '#simulate_partition' do
    it 'removes partitioned nodes from neighbors and triggers a re-election' do
      node1.add_neighbor(node2)
      node1.add_neighbor(node3)
      node2.add_neighbor(node1)
      node3.add_neighbor(node1)

      node1.become_leader

      node1.simulate_partition([node2])

      expect(node1.neighbors).to_not include(node2)
      expect(node2.statuses[0]).to eq(:died)
      expect(node1.log).to include("Node 1 simulating partition from Nodes 2")
    end
  end

  describe '#there_is_leader?' do
    it 'returns true if the node or any neighbor is a leader' do
      node1.add_neighbor(node2)
      node2.become_leader

      expect(node1.there_is_leader?).to be true
    end
  end
end
