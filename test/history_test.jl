function history_test()
    @testset "History" begin
        fPath = mdl.test_history_path();
        nPoints = 5;
        nParams = 4;
        h = mdl.make_test_history(nPoints, nParams);
        @test h isa History;

        solnV = (1 : nParams) ./ 2;
        startV = solnV ./ 2;
        fVal = 0.8;
        mdl.add_to_history!(h, 1, startV, solnV, fVal, :a);
        @test n_solved(h) == 1;

        save_history(h);
        h2 = load_history(fPath);
        @test n_solved(h) == 1;
        @test all(h2.solnV[1] .≈ solnV);

        mdl.add_to_history!(h, 2, startV .+ 0.2, solnV .+ 0.2, fVal - 0.1, :b);
        mdl.add_to_history!(h, 3, startV .+ 0.1, solnV .+ 0.1, fVal + 0.1, :c);
        @test n_solved(h) == 3;
        bestSolV, bestVal, bestFlag = best_point(h);
        @test all(isapprox.(bestSolV, solnV .+ 0.2));
        @test isapprox(bestVal, fVal - 0.1);
        @test bestFlag == :b;
    end
end

@testset "History All" begin
    history_test();
end

# ------------------