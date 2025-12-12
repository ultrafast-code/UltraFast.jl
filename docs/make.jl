using UltraFast
using Documenter

DocMeta.setdocmeta!(UltraFast, :DocTestSetup, :(using UltraFast); recursive=true)

makedocs(;
    modules=[UltraFast],
    authors="R.J.L.F. Berns, P.F.A Coenders, G. Fabiani and J.H. Mentink",
    repo="https://gitlab.science.ru.nl/ultrafast-code/ultrafast.jl/blob/{commit}{path}#{line}",
    sitename="UltraFast.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://ultrafast-code.pages.science.ru.nl/ultrafast.jl",
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

