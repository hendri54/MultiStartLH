using MultiStartLH
using Documenter

DocMeta.setdocmeta!(MultiStartLH, :DocTestSetup, :(using MultiStartLH); recursive=true)

makedocs(;
    modules=[MultiStartLH],
    authors="hendri54 <hendricksl@protonmail.com> and contributors",
    repo="https://github.com/hendri54/MultiStartLH.jl/blob/{commit}{path}#{line}",
    sitename="MultiStartLH.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
