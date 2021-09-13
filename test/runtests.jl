using MultiStartLH
using Test

mdl = MultiStartLH;

isdir(test_dir())  ||  mkpath(test_dir());


@testset "MultiStartLH.jl" begin
    include("history_test.jl");
    include("update_rule_test.jl");
    include("optim_test.jl");
end
