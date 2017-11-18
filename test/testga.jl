
using GeneticAlgorithms

module testga

    using GeneticAlgorithms

    mutable struct TestMonster <: Entity
        genes
        fitness

        TestMonster(num) = new(num, nothing)
    end

    # -------

    function create_entity(num)
        TestMonster(num)
    end

    function fitness(entity)
        println("score: ", entity.genes)
        entity.genes
    end

    function group_entities(grouped::Channel, population)
        if population[1].fitness >= 16
            return
        end

        freeze(population[1])

        for i in 1:length(population)
            put!(grouped, [1, i])
        end
    end

    function crossover(entities)
        TestMonster(max(entities[1].genes, entities[2].genes))
    end

    function mutate(entity)
        if rand(Float64) > 0.5
            entity.genes += 1
        end
    end

end

# -------

function test_serial()
    runga(testga; initial_pop_size = 8)
end

# -------

function test_parallel(; nprocs_to_add = 2)
    addprocs(nprocs_to_add)
    @everywhere include(Pkg.dir("GeneticAlgorithms", "test", "testga.jl"))

    println("nprocs: $(nprocs())")

    runga(testga; initial_pop_size = 8)
end
