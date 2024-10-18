require_relative 'lib/node.rb'

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