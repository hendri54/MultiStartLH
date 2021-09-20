using Dates

function tiktak_test()
    @testset "TikTakRule" begin
        nPoints = 17;
        nParams = 3;
        ttr = TikTakRule(; nPoints);
        h = mdl.make_test_history(nPoints, nParams);
        solnV = first(h.guessesV) .+ 0.1;
        fVal = 9.8;
        for j = 1 : nPoints
            startV = mdl.new_guess(ttr, h, j);
            # println(startV);
            @test size(startV) == size(solnV);
            p = Point(startV, solnV .+ (1/j), fVal + 1/j, fVal - 1/j,
                :success, Second(120 + j), 10 * j);
            mdl.add_to_history!(h, j, p);
        end
    end
end

@testset "UpdateRule" begin
    tiktak_test();
end

# -----------