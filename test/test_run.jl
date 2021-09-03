using GeneticAlgorithms
include("equalityga.jl")

model = runga(equalityga; initial_pop_size = 16)

population(model)