module Testga

using GA

# -------

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

function review_entities(population)
    best = population[end]

    if best.entity.genes >= 16
        return true
    end

    return false
end

function group_entities(population)
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
