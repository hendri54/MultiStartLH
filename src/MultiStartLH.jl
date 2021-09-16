module MultiStartLH

using Dates, DocStringExtensions, FileIO, JLD2, Random

export test_dir;

include("logging.jl");
include("history.jl");
include("update_rule.jl");
include("multistart.jl");

test_dir() = normpath(joinpath(@__DIR__, "..", "testfiles"));


end # module
