using GeneticAlgorithms
include(joinpath(@__DIR__, "equalityga.jl"))

model = runga(equalityga; initial_pop_size = 16)

population(model) # the the latest population when the GA exited
