
addprocs(1)

println("num procs: ", nprocs())

require("../src/GA.jl")
import GA

require("testga.jl")
import Testga

GA.run(Testga; initial_pop_size = 8)

