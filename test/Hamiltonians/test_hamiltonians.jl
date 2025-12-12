@testset "Heisenberg" begin
    lattice = UltraFast.LatticeConfig(Lx=4, Ly=4)
    H = UltraFast.Hamiltonians.Heisenberg(lattice=lattice)
    @test UltraFast.reference_energy(H)["QMC"] == -0.701777

    @test UltraFast.is_chain(lattice) == false
    @test UltraFast.is_square(lattice) == true

    relative_error, metrics = UltraFast.relative_error(-0.7, H)
    @test relative_error == 0.0025321434016789216
    @test metrics["method"] == "QMC"
    @test metrics["energy"] == -0.701777

    lattice_chain = UltraFast.LatticeConfig(Lx=4, Ly=1)
    H_chain = UltraFast.Hamiltonians.Heisenberg(lattice=lattice_chain)
    @test UltraFast.reference_energy(H_chain)["DMRG"] == -0.49999999999999994
    @test UltraFast.is_chain(lattice_chain) == true
    @test UltraFast.is_square(lattice_chain) == false
end