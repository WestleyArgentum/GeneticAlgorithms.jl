
module GA

importall Base

export  EntityData,
        GAmodel,

        freezedry,
        run

# -------

type GAmodel
    initial_pop_size::Int
    curr_generation::Int

    curr_pop::Array
    freezer::Array

    GAmodel() = new(0, 1, EntityData[], EntityData[])
end

# -------

type EntityData
    entity
    generation::Int
    score
end

function EntityData(entity, generation::Int)
    EntityData(entity, generation, nothing)
end

function EntityData(entity, model::GAmodel)
    EntityData(entity, model.curr_generation, nothing)
end

isless(a::EntityData, b::EntityData) = (a.score < b.score)

# -------

function freeze(model::GAmodel, entity::EntityData)
    push!(model.freezer, entity)
end

function freeze(model::GAmodel, entity)
    entitydata = EntityData(entity, model.curr_generation)
    freeze(model, entitydata)
end

function run(model::GAmodel)
    reset_model(model)
    create_initial_population(model)

    while true
        evaluate_population(model)

        review_entities(model.curr_pop) && break

        groupings = group_entities(model.curr_pop)

        crossover_population(model, groupings)
        mutate_population(model)
    end

end

# -------

function reset_model(model::GAmodel)
    model.curr_generation = 1
    empty!(model.curr_pop)
    empty!(model.freezer)
end

function create_initial_population(model::GAmodel)
    for i = 1:model.initial_pop_size
        entitydata = EntityData(create_entity(i), model.curr_generation)
        push!(model.curr_pop, entitydata)
    end
end

function evaluate_population(model::GAmodel)
    pop_size = length(model.curr_pop)
    for i = 1:pop_size
        entitydata = model.curr_pop[i]
        entitydata.score = eval_entity(entitydata.entity)
    end
end

function crossover_population(model::GAmodel, groupings)
    old_pop = model.curr_pop

    model.curr_pop = EntityData[]
    sizehint(model.curr_pop, length(old_pop))

    model.curr_generation = model.curr_generation + 1

    for group in groupings
        parents = { old_pop[i].entity for i in group }
        entitydata = EntityData(crossover(parents), model.curr_generation)
        push!(model.curr_pop, entitydata)
    end
end

function mutate_population(model::GAmodel)
    for entity in model.curr_pop
        mutate(entity.entity)
    end
end

end
