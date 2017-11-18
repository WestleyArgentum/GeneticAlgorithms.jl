using GeneticAlgorithms
addprocs(2)
println("nprocs: $(nprocs())")

push!(LOAD_PATH, @__DIR__)
@everywhere using equalityga

model = runga(equalityga; initial_pop_size = 16)

population(model) # the the latest population when the GA exited
