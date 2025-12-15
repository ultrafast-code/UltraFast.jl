using UltraFast
using Documenter

DocMeta.setdocmeta!(UltraFast, :DocTestSetup, :(using UltraFast); recursive=true)

makedocs(;
    modules=[UltraFast],
    authors="R.J.L.F. Berns, P.F.A Coenders, G. Fabiani and J.H. Mentink",
    repo="https://github.com/ultrafast-code/UltraFast.jl/blob/{commit}{path}#{line}",
    sitename="UltraFast.jl",
    format=Documenter.HTML(;
        canonical="https://ultrafast-code.github.io/UltraFast.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Models" => "chapters/models.md",
        "Lattice" => "chapters/lattice.md",
        "Docs" => "docs.md",
        "Helpers" => "chapters/extra.md",
    ],
)

deploydocs(;
    repo="github.com/ultrafast-code/UltraFast.jl",
    devbranch="main",
)
