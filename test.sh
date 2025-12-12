julia --project=@. -e '
        using Pkg
        Pkg.build()
        Pkg.test()'