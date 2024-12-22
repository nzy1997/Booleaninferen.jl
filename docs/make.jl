using BooleanInference
using Documenter

DocMeta.setdocmeta!(BooleanInference, :DocTestSetup, :(using BooleanInference); recursive=true)

makedocs(;
    modules=[BooleanInference],
    authors="nzy1997",
    sitename="BooleanInference.jl",
    format=Documenter.HTML(;
        canonical="https://nzy1997.github.io/BooleanInference.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/nzy1997/BooleanInference.jl",
    devbranch="main",
)
