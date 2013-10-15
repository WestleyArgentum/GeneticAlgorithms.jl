
using GA

module testga

    type TestMonster
        genes
    end

    # -------

    function create_entity(num)
        TestMonster(num)
    end

    function eval_entity(entity)
        println("score: ", entity.genes)
        entity.genes
    end

    function group_entities(population)
        if population[end].entity.genes >= 16
            return
        end

        pop_count = length(population)
        for i in 1:pop_count
            produce([i, pop_count])
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
    GA.run(testga; initial_pop_size = 8)
end

# -------

function test_parallel(; nprocs_to_add = 2)
    addprocs(nprocs_to_add)
    require("GA/test/testga.jl")

    println("nprocs: $(nprocs())")

    GA.run(testga; initial_pop_size = 8)
end
