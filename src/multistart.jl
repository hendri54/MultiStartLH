export MultiStart, n_points, n_params, optimize

"""
	$(SIGNATURES)

Contains information to run a multistart optimization.

# Fields

- optFct: 
    Function to be optimized. Signature:
    `solnV, fVal, exitFlag = optFct(guessV)`
- guessesV:
    Vector of guesses. Each guess is a Vector{Float64}
- historyFn:
    Full path where optimization history will be stored.
- fTol, fTolN:
    Stop if fVal improves by less than `fTol` over the last `fTolN` points
    This can terminate early.
"""
mutable struct MultiStart{F, U}
    optFct :: F
    updateRule :: U
    guessesV :: Vector{Vector{Float64}}
    historyFn :: String
    maxHours :: Float64
    fTol :: Float64
    fTolN :: Integer
end

"""
	$(SIGNATURES)

Number of points to be evaluated.
"""
n_points(m :: MultiStart{F, U}) where {F, U} = length(m.guessesV);

"""
	$(SIGNATURES)

Number of calibrated parameters in each point.
"""
n_params(m :: MultiStart{F, U}) where {F, U} = 
    length(first(m.guessesV));


"""
	$(SIGNATURES)

Run the multistart optimization.
"""
function optimize(m :: MultiStart{F, U}, 
        io = stdout) where {F, U}

    log_msg(1, io, start_header(m));
    startTime = Dates.now();
    h = init_history(m.historyFn, m.guessesV);

    done = false;
    j = 0;
    while !done
        j += 1;
        newGuessV = new_guess(m.updateRule, h, j);
        log_msg(2, io, point_start_header(j));
        # startTime = Dates.now();
        newPoint = m.optFct(newGuessV);
        # endTime = Dates.now();
        log_msg(2, io, finish_point_header(j, newPoint));
        add_to_history!(h, j, newPoint);
        save_history(h);
        continue_run(m, h, j, startTime; io)  ||  (done = true);
    end
    bestPoint = best_point(h);
    log_msg(1, io, finish_header(bestPoint, startTime, n_points(m)));
    return bestPoint.solnV, bestPoint.fVal, bestPoint.exitFlag
end


"""
	$(SIGNATURES)

Decide whether to continue running at the end of iteration `j`.
Report reason for termination.
"""
function continue_run(m :: MultiStart{F,U}, h :: History,
            j, startTime; io = stdout) where {F,U}
    cont = true;
    if reached_max_time(startTime, m.maxHours)
        log_msg(3, io, "Max time reached.");
        cont = false;
    end
    if j >= n_points(m)
        log_msg(3, io, "All points evaluated.");
        cont = false;
    end
    if j > m.fTolN
        fDiff = fval_improvement(h, j, m.fTolN);
        if fDiff < m.fTol
            fDiffStr = round(fDiff; digits = 2);
            log_msg(3, io, "Difference in fVal below fTol: $fDiffStr < $(m.fTol)");
            cont = false;
        end
    end
    return cont
end

# function fval_improvement_too_small(m :: MultiStart{F,U}, h :: History, 
#         j) where {F,U}
#     if j > m.
#         return fval_improvement(h, j, n) < m.fTol;
#     else
#         return false
#     end
# end

# Improvement during last `n` points relative to best point of previous history.
function fval_improvement(h :: History, j :: Integer, n :: Integer)
    @assert (j > n)  "Do not have past $n points with history of length $j";
    fValV = f_values(h);
    fPast = minimum(fValV[1 : (j-n)]);
    fNew = minimum(fValV[(j-n+1) : j]);
    fDiff = fPast - fNew;
    return fDiff
end


reached_max_time(startTime, maxHours :: Float64) = 
    seconds_elapsed(startTime, Dates.now()) / 3600 >= maxHours;

seconds_elapsed(startTime, endTime) = Dates.value(endTime - startTime) / 1000;


# +++++ move to general purpose pkg
function split_duration(dSeconds :: Integer)
    dHours, hRem = divrem(dSeconds, 3600);
    dMin, mRem = divrem(hRem, 60);
    dSec = round(Int, mRem);
    return dHours, dMin, dSec
end

function format_duration(dSeconds :: Integer)
    dHours, dMin, dSec = split_duration(dSeconds);
    d = DateTime(2020,1,1,dHours,dMin,dSec);
    if dHours > 0
        return Dates.format(d, "HH:MM") * " hr";
    elseif dMin > 0
        return Dates.format(d, "MM:SS") * " min";
    else
        return Dates.format(d, "SS") * " sec";
    end
end


## -----------  Headers to display

start_header(m :: MultiStart{F, U}) where {F,U} = 
    "Multistart with $(n_points(m)) points begins at $(format_time())";

point_start_header(j :: Integer) = 
    "Starting point $j at $(format_time())";

finish_point_header(j :: Integer, p :: Point{F}) where F = 
    "Point $j completed at $(format_time()) with [fVal $(round(p.fVal, digits = 3))]  and  [exitFlag $(p.exitFlag)]";

function finish_header(bestPoint :: Point{F}, startTime, nPoints) where F
    avgTime = round(Int, average_time(startTime, Dates.now(), nPoints));
    avgTimeStr = format_duration(avgTime);
    return "MultiStart completed at $(format_time()) \n  fVal $(round(bestPoint.fVal, digits = 3)),  exitFlag $(bestPoint.exitFlag) \n  Average time per point: $(avgTimeStr)."
end

format_time(d = Dates.now()) = Dates.format(d, "u-d, HH:MM");

average_time(dStart, dStop, n) = seconds_elapsed(dStart, dStop) / n;


# -------------