export Point
export History, best_point, n_solved, n_params, load_history, save_history

mutable struct Point{F}
    guessV :: Vector{F}
    solnV :: Vector{F}
    fStart :: F
    fVal :: F
    exitFlag :: Symbol
    runTime :: Second
    nEvals :: Int
end

empty_point(F) = 
    Point{F}(zeros(F, 1), zeros(F, 1), 
        zero(F), zero(F),
        :notRun, Second(0), 0);

n_params(p :: Point{F}) where F = length(p.guessV);
solved(p :: Point{F}) where F = (p.exitFlag != :notRun);
f_value(p :: Point{F}) where F = p.fVal;

"""
	$(SIGNATURES)

Stores all points computed during the multistart.
Guesses are filled at construction. Solutions are filled in in any order.
"""
mutable struct History{F}
    fPath :: String
    # Initial population
    guessesV :: Vector{Vector{Float64}}
    pointV :: Vector{Point{F}}
    # # Starting guesses
    # startV :: Vector{Vector{Float64}}
    # # Solutions
    # solnV :: Vector{Vector{Float64}}
    # fValStartV :: Vector{Float64}
    # fValV :: Vector{Float64}
    # exitFlagV :: Vector{Symbol}
    # runTimeV :: Vector{Second}
end

n_params(h :: History{F}) where F = length(first(h.guessesV));
n_solved(h :: History{F}) where F = sum(solved.(h.pointV));
f_values(h :: History{F}) where F = f_value.(h.pointV[ 1 : n_solved(h)]);

function init_history(fPath :: String, 
            guessesV :: AbstractVector{Vector{F1}}) where F1
    # nParams = length(first(guessesV));
    nPoints = length(guessesV);
    return History(fPath, guessesV, fill(empty_point(Float64), nPoints));
        # guessesV,
        # [Vector{F1}()  for j = 1 : nPoints], 
        # [Vector{F1}()  for j = 1 : nPoints], 
        # fill(1e8, nPoints),
        # fill(1e8, nPoints), 
        # fill(:notRun, nPoints),
        # fill(Second(0), nPoints))
end

function add_to_history!(h :: History, j :: Integer, p :: Point{F}) where F
    @assert n_params(p) == n_params(h);
    # @assert length(startV) == n_params(h);
    # h.nPoints += 1;
    @assert !solved(h.pointV[j]);
    h.pointV[j] = p;
    # h.startV[j] = startV;
    # h.solnV[j] = solnV;
    # h.fValStartV[j] = fValStart;
    # h.fValV[j] = fVal;
    # h.exitFlagV[j] = exitFlag;
    # h.runTimeV[j] = round(runTime, Second);
end

"""
	$(SIGNATURES)

Return best point of a history: parameters, fVal, exitFlag
"""
function best_point(h :: History)
    @assert n_solved(h) > 0;
    fVal, idx = findmin(f_values(h));
    return h.pointV[idx]
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