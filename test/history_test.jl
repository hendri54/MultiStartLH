using Dates, Test
using MultiStartLH

mdl = MultiStartLH;

function history_test()
    @testset "History" begin
        fPath = mdl.test_history_path();
        nPoints = 5;
        nParams = 4;
        h = mdl.make_test_history(nPoints, nParams);
        @test h isa History;

        solnV = collect(1 : nParams) ./ 2;
        startV = solnV ./ 2;
        fVal = 0.8;
        p1 = Point(startV, solnV, fVal + 1.0, fVal, :a, Second(210), 35);
        mdl.add_to_history!(h, 1, p1);
        @test n_solved(h) == 1;

        save_history(h);
        h2 = load_history(fPath);
        @test n_solved(h) == 1;
        p11 = h2.pointV[1];
        @test all(p11.solnV .≈ solnV);

        p2 = Point(startV .+ 0.2, solnV .+ 0.2, 
            fVal + 1.1, fVal - 0.1, :b, Second(120), 45);
        mdl.add_to_history!(h, 2, p2);
        p3 = Point(startV .+ 0.1, solnV .+ 0.1, 
            fVal + 2.1, fVal + 0.1, :c, Second(90), 66);
        mdl.add_to_history!(h, 3, p3);
        @test n_solved(h) == 3;
        pBest = best_point(h);
        @test all(isapprox.(pBest.solnV, solnV .+ 0.2));
        @test isapprox(pBest.fVal, fVal - 0.1);
        @test pBest.exitFlag == :b;
    end
end

@testset "History All" begin
    history_test();
end

# ------------------