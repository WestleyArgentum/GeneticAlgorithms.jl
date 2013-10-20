
using GA

module testga

    type TestMonster
        genes
        score

        TestMonster(num) = new(num, nothing)
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
        if population[1].score >= 16
            return
        end

        for i in 1:length(population)
            produce([1, i])
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
