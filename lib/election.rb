# frozen_string_literal: true

# Election module that encapsulates all the logic related to the election process in the Raft consensus algorithm.
module Election
  # Simulate the election process
  def start_election
    become_candidate
    request_votes
  end

  def become_candidate
    return if there_is_leader?

    @role = :candidate
    @current_term += 1
    @voted_for = nil
    log_action("Node #{@id} became candidate for term #{@current_term}")
    request_votes
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

  # Handle receiving a vote
  def receive_vote(vote)
    return unless @role == :candidate

    log_action("Node #{@id} received vote from Node #{vote[:from]} for term #{vote[:term]}")

    return unless vote[:term] == @current_term && vote[:granted]

    @vote_count += 1
    become_leader if @vote_count > (@neighbors.size / 2)
  end

  # Send vote response to the requesting candidate
  def send_vote_response(candidate_id, granted)
    log_action("Node #{@id} sending vote response to Node #{candidate_id}: #{granted}")
    neighbor = @neighbors.find { |n| n.id == candidate_id }
    neighbor&.receive_vote(term: @current_term, from: @id, granted: granted)
  end

  def there_is_leader?
    leader? || any_neighbor_is_leader?
  end

  def become_leader
    @role = :leader
    log_action("Node #{@id} became leader for term #{@current_term}")
    update_follower_statuses
  end
end
