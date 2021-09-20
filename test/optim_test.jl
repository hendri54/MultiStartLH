using Dates, Random, Test
using MultiStartLH

mdl = MultiStartLH;

function test_optimizer(guessV)
    solnV = guessV .- 0.1;
    fVal = sum(solnV);
    exitFlag = :success;
    fValStart = fVal + 1.0;
    nEvals = round(Int, sum(guessV));
    p = Point(guessV, solnV, fValStart, fVal, :success, Second(4), nEvals);
    return p
end

function opt_test()
    @testset "MultiStart" begin
        rng = MersenneTwister(434);
        historyFn = mdl.test_history_path();
        maxHours = 0.7;
        fTol = 0.05;
        fTolN = 3;
        nPoints = 20;
        nParams = 4;
        guessesV = [1.0 .+ rand(rng, nParams)  for j = 1 : nPoints];
        ttr = TikTakRule(; nPoints);

        m = MultiStart(test_optimizer, ttr, guessesV, historyFn, maxHours, 
            fTol, fTolN);
        solnV, fVal, exitFlag = optimize(m);
        @test solnV isa Vector{Float64};
        @test fVal > 0.0;
        @test exitFlag isa Symbol;
    end
end

@testset "Optimization" begin
    opt_test();
end

# -------------