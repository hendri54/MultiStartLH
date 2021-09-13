export History, best_point, n_solved, n_params, load_history, save_history

"""
	$(SIGNATURES)

Stores all points computed during the multistart.
Guesses are filled at construction. Solutions are filled in in any order.
"""
mutable struct History
    fPath :: String
    # Initial population
    guessesV :: Vector{Vector{Float64}}
    # Starting guesses
    startV :: Vector{Vector{Float64}}
    # Solutions
    solnV :: Vector{Vector{Float64}}
    fValV :: Vector{Float64}
    exitFlagV :: Vector{Symbol}
end

n_params(h :: History) = length(first(h.guessesV));
n_solved(h :: History) = sum(h.exitFlagV .!= :notRun);

function init_history(fPath :: String, 
            guessesV :: AbstractVector{Vector{F1}}) where F1
    # nParams = length(first(guessesV));
    nPoints = length(guessesV);
    return History(fPath, 
        guessesV,
        [Vector{F1}()  for j = 1 : nPoints], 
        [Vector{F1}()  for j = 1 : nPoints], 
        fill(1e8, nPoints), 
        fill(:notRun, nPoints))
end

function add_to_history!(h :: History, j :: Integer, startV, solnV, fVal, exitFlag)
    @assert length(solnV) == n_params(h);
    @assert length(startV) == n_params(h);
    # h.nPoints += 1;
    @assert h.exitFlagV[j] == :notRun;
    h.startV[j] = startV;
    h.solnV[j] = solnV;
    h.fValV[j] = fVal;
    h.exitFlagV[j] = exitFlag;
end

"""
	$(SIGNATURES)

Return best point of a history: parameters, fVal, exitFlag
"""
function best_point(h :: History)
    @assert n_solved(h) > 0;
    fVal, idx = findmin(h.fValV);
    return h.solnV[idx], fVal, h.exitFlagV[idx]
end

function save_history(h :: History)
    jldsave(h.fPath; h);
end

"""
	$(SIGNATURES)

Load a history. Returns a `History` object.
"""
function load_history(histFn)
    @assert isfile(histFn);
    h = load(histFn, "h");
    @assert h isa History;
    return h
end


function make_test_history(nPoints, nParams; 
            fPath = test_history_path())
    lb = 1.0;
    ub = 2.0;
    rng = MersenneTwister(23);
    guessesV = [lb .+ (ub - lb) .* rand(rng, nParams)  for j = 1 : nPoints];
    h = init_history(fPath, guessesV);
    return h
end

test_history_path() = joinpath(test_dir(), "history_test.jld2");

# ----------