export TikTakRule

abstract type AbstractUpdateRule end

# For generating new points. Defaults based on Guvenen et al. (2019)
Base.@kwdef struct TikTakRule <: AbstractUpdateRule
    nPoints :: Int
    θ_min :: Float64 = 0.1
    θ_max :: Float64 = 0.995
    θ_pow :: Float64 = 0.5
    lb :: Float64 = 1.0
    ub :: Float64 = 2.0
end

function new_guess(ur :: TikTakRule, h :: History, j :: Int) 
    if j == 1
        guessV = first(h.guessesV);
    else
        wt = weight_parameter(ur, j);
        bestV, _ = best_point(h);
        guessV = wt .* bestV .+ (1 - wt) .* h.guessesV[j];
    end
    clamp!(guessV, ur.lb, ur.ub);
    return guessV
end

function weight_parameter(ur :: TikTakRule, j :: Integer)
    return clamp((j / ur.nPoints) ^ ur.θ_pow,  
        ur.θ_min, ur.θ_max)
end

function weight_sequence(ur :: TikTakRule, jMax :: Integer)
    return [weight_parameter(ur, j)  for j = 1 : jMax]
end

# ---------------