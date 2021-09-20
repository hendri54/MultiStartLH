export AbstractUpdateRule, TikTakRule
export new_guess, weight_parameter, weight_sequence

"""
	$(SIGNATURES)

Abstract type for generating new guesses from the history of already computed points and from the set of starting points provided by the user.
"""
abstract type AbstractUpdateRule end

"""
	$(SIGNATURES)

Generate a sequence of weights for `jMax` points. Useful for tuning the parameters of the update rule.
"""
function weight_sequence(ur :: AbstractUpdateRule, jMax :: Integer)
    return [weight_parameter(ur, j)  for j = 1 : jMax]
end


"""
	$(SIGNATURES)

For generating new points. Defaults based on 

Arnoud, Antoine, Fatih Guvenen, and Tatjana Kleineberg. 2019. “Benchmarking Global Optimizers.” Working Paper 26340. National Bureau of Economic Research. https://doi.org/10.3386/w26340.
"""
Base.@kwdef struct TikTakRule <: AbstractUpdateRule
    nPoints :: Int
    θ_min :: Float64 = 0.1
    θ_max :: Float64 = 0.995
    θ_pow :: Float64 = 0.5
    # Bounds for elements of the guess vector.
    lb :: Float64 = 1.0
    ub :: Float64 = 2.0
end

"""
	$(SIGNATURES)

Make a new guess vector from the history of points computed so far and from the set of user provided starting points. Implements `TikTak`.
"""
function new_guess(ur :: TikTakRule, h :: History, j :: Int) 
    if j == 1
        guessV = first(h.guessesV);
    else
        wt = weight_parameter(ur, j);
        pBest = best_point(h);
        guessV = wt .* pBest.solnV .+ (1 - wt) .* h.guessesV[j];
    end
    clamp!(guessV, ur.lb, ur.ub);
    return guessV
end

"""
	$(SIGNATURES)

`TikTak` weight parameter.
"""
function weight_parameter(ur :: TikTakRule, j :: Integer)
    return clamp((j / ur.nPoints) ^ ur.θ_pow,  
        ur.θ_min, ur.θ_max)
end


# ---------------