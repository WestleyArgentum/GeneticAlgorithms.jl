using GeneticAlgorithms
addprocs(2)
@everywhere include(joinpath(@__DIR__, "equalityga.jl"))

println("nprocs: $(nprocs())")

model = runga(equalityga; initial_pop_size = 16)

population(model) # the the latest population when the GA exited
