function X=Run_Model(problem)
    tic
    x= intlinprog(problem);
    Candidate=problem.Candidate;
    X=reshape(sparse(x),size(Candidate));
    X=logical(X);
    ispaired=has_candidate(X); % ispaired(i)=1 if the ith trip is paired, otherwise 0
    paired_number=nnz(ispaired);
    fprintf('we paired %d trips using integer programming\n',paired_number);
    t1=toc;
    fprintf('Running time: %f s \n',t1);
end
