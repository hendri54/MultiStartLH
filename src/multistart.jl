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
"""
mutable struct MultiStart{F, U}
    optFct :: F
    updateRule :: U
    guessesV :: Vector{Vector{Float64}}
    historyFn :: String
    maxHours :: Float64
    # Stop if last two points fVal differs by less than
    fTol :: Float64
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

    println(io, start_header(m));
    startTime = Dates.now();
    h = init_history(m.historyFn, m.guessesV);

    done = false;
    j = 0;
    while !done
        j += 1;
        newGuessV = new_guess(m.updateRule, h, j);
        println(io, point_start_header(j));
        solnV, fVal, exitFlag = m.optFct(newGuessV);
        println(io, finish_point_header(j, fVal, exitFlag));
        add_to_history!(h, j, newGuessV, solnV, fVal, exitFlag);
        save_history(h);
        continue_run(m, h, j, startTime; io)  ||  (done = true);
    end
    solnV, fVal, exitFlag = best_point(h);
    println(io, finish_header(fVal, exitFlag, startTime, n_points(m)));
    return solnV, fVal, exitFlag
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
        println(io, "Max time reached.");
        cont = false;
    end
    if j >= n_points(m)
        println(io, "All points evaluated.");
        cont = false;
    end
    if (j > 1)
        fDiff = abs(h.fValV[j-1] - h.fValV[j]);
        if fDiff < m.fTol
            fDiffStr = round(fDiff; digits = 2);
            println(io, "Difference in fVal below fTol: $fDiffStr < $(m.fTol)");
            cont = false;
        end
    end
    return cont
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

finish_point_header(j :: Integer, fVal, exitFlag) = 
    "Point $j completed at $(format_time()) with [fVal $(round(fVal, digits = 3))]  and  [exitFlag $exitFlag]";

function finish_header(fVal, exitFlag, startTime, nPoints)
    avgTime = round(Int, average_time(startTime, Dates.now(), nPoints));
    avgTimeStr = format_duration(avgTime);
    return "MultiStart completed at $(format_time()) \n  fVal $(round(fVal, digits = 3)),  exitFlag $exitFlag \n  Average time per point: $(avgTimeStr)."
end

format_time(d = Dates.now()) = Dates.format(d, "u-d, HH:MM");

average_time(dStart, dStop, n) = seconds_elapsed(dStart, dStop) / n;


# -------------