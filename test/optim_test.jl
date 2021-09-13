using Random, Test
using MultiStartLH

mdl = MultiStartLH;

function test_optimizer(guessV)
    solnV = guessV .- 0.1;
    fVal = sum(solnV);
    exitFlag = :success;
    return solnV, fVal, exitFlag
end

function opt_test()
    @testset "MultiStart" begin
        rng = MersenneTwister(434);
        historyFn = mdl.test_history_path();
        maxHours = 0.7;
        fTol = 0.05;
        nPoints = 20;
        nParams = 4;
        guessesV = [1.0 .+ rand(rng, nParams)  for j = 1 : nPoints];
        ttr = TikTakRule(; nPoints);

        m = MultiStart(test_optimizer, ttr, guessesV, historyFn, maxHours, fTol);
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