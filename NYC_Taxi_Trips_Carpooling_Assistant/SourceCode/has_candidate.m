function index=has_candidate(Candidate) 
%% the output is a logical index that filter out those that has a candidate to pair with
    index=any(Candidate-eye(size(Candidate,1)),2);
end
