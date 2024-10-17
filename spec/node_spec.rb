# spec/node_spec.rb
require 'rspec'
require_relative '../lib/node' # Update with the path to your implementation file

RSpec.describe RandomTimeGenerator do
  describe '.random_time' do
    it 'generates a random time within the specified range' do
      min = 10
      max = 100
      result = RandomTimeGenerator.random_time(min, max)

      expect(result).to be_between(min, max)
    end

    it 'raises an ArgumentError if min is greater than or equal to max' do
      expect { RandomTimeGenerator.random_time(100, 100) }.to raise_error(ArgumentError)
      expect { RandomTimeGenerator.random_time(100, 50) }.to raise_error(ArgumentError)
    end
  end
end

RSpec.describe Node do
  let(:node1) { Node.new(1) }
  let(:node2) { Node.new(2) }

  describe '#initialize' do
    it 'initializes a node with an ID' do
      expect(node1.id).to eq(1)
      expect(node1.neighbors).to eq([])
      expect(node1.log).to be_an(Array)
    end
  end

  describe '#add_neighbor' do
    it 'adds a neighbor to the node' do
      node1.add_neighbor(node2)
      expect(node1.neighbors).to include(node2)
    end
  end

  describe '#send_message' do
    before { node1.add_neighbor(node2) }

    it 'does not send a message to a non-neighbor' do
      node3 = Node.new(3)
      expect { node1.send_message({ type: :state_proposal, state: 1 }, node3) }
        .to change { node2.log.length }.by(0)
    end
  end

  describe '#propose_state' do
    it 'proposes a state when there is no leader' do
      node1.propose_state(2)
      expect(node1.state).to eq(2)
      expect(node1.log).to include("Node 1 (candidate) is proposing state 2")
    end
  end

  describe '#simulate_partition' do
    it 'removes neighbors and starts a new election' do
      node1.add_neighbor(node2)
      node1.simulate_partition([node2])
      expect(node1.neighbors).not_to include(node2)
      expect(node1.role).to eq(:candidate)
    end
  end
end
