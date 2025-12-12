# How to develop documentation?

In this project, we use Documenter.jl to generate documentation. The documentation is written in Markdown format and stored in the `docs/src` directory. The `make.jl` script in the `docs` directory is used to generate the documentation.

To generate the documentation, run the following command in the Julia REPL:

```
cd docs
julia --project=. make.jl
```

This command generates the documentation in the `docs/build` directory.

To view the documentation, one can use LiveServer by running the following command in the Julia REPL:

```
cd docs
julia --project=. -e 'using LiveServer; serve(dir="build")'
```

Or just run the `rundocs.sh` script:

```sh
source docs/rundocs.sh
```