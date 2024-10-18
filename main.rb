# frozen_string_literal: true

require_relative 'lib/node'
require 'terminal-table'

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

# Display logs in table format
def display_log_in_table(node_id, log)
  rows = log.split("\n").map.with_index { |log_entry, index| [index + 1, log_entry] }
  table = Terminal::Table.new(
    title: "Node #{node_id} Log",
    headings: ['Step', 'Log Entry'],
    rows: rows
  )
  puts table
end

# Output logs for each node in table format
display_log_in_table(1, node1.retrieve_log)
display_log_in_table(2, node2.retrieve_log)
display_log_in_table(3, node3.retrieve_log)
