
addprocs(1)

println("num procs: ", nprocs())

using GA

require("GA/test/testga.jl")
import Testga

GA.run(Testga; initial_pop_size = 8)

