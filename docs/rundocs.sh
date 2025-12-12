julia --project=docs -e '
        using Pkg
        Pkg.develop(PackageSpec(path=pwd()))
        Pkg.instantiate()
        using Documenter: doctest, DocMeta
        using UltraFast
        DocMeta.setdocmeta!(UltraFast,:DocTestSetup,:(using UltraFast);recursive=true)
        doctest(UltraFast)
        include("docs/make.jl")'

julia --project=docs -e 'using LiveServer; serve(dir="docs/build")'