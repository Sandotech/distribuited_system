# frozen_string_literal: true

# Generate a Random Time that works as a flag
class RandomTimeGenerator
  def self.random_time(min_ms = 1, max_ms = 1000)
    raise ArgumentError, 'Minimum time must be less than maximum time' if min_ms >= max_ms

    rand(min_ms..max_ms)
  end
end
