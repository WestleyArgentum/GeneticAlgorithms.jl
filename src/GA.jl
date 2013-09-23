
module GA

# -------

importall Base

export  EntityData,
        GAmodel,

        freeze,
        run

# -------

type GAmodel
    initial_pop_size::Int
    curr_generation::Int

    curr_pop::Array
    freezer::Array

    rng::AbstractRNG

    ga

    GAmodel() = new(0, 1, EntityData[], EntityData[], MersenneTwister(time_ns()), nothing)
end

global _g_model

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

freeze(entity) = freeze(_g_model, entity)

function freeze(model::GAmodel, entity::EntityData)
    push!(model.freezer, entity)
    println("Freezing: ", entity)
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

        model.ga.review_entities(model.curr_pop) && break

        groupings = model.ga.group_entities(model.curr_pop)

        crossover_population(model, groupings)
        mutate_population(model)
    end

end

# -------

function reset_model(model::GAmodel)
    global _g_model = model

    model.curr_generation = 1
    empty!(model.curr_pop)
    empty!(model.freezer)
end

function create_initial_population(model::GAmodel)
    for i = 1:model.initial_pop_size
        entitydata = EntityData(model.ga.create_entity(i), model.curr_generation)
        push!(model.curr_pop, entitydata)
    end
end

function internal_eval_entity(model::GAmodel, ed::EntityData)
    ed.score = model.ga.eval_entity(ed.entity)
    ed
end

function evaluate_population(model::GAmodel)
    model.curr_pop = pmap((entity)->internal_eval_entity(model, entity), model.curr_pop)
    sort!(model.curr_pop)
end

function crossover_population(model::GAmodel, groupings)
    old_pop = model.curr_pop

    model.curr_pop = EntityData[]
    sizehint(model.curr_pop, length(old_pop))

    model.curr_generation = model.curr_generation + 1

    for group in groupings
        parents = { old_pop[i].entity for i in group }
        entitydata = EntityData(model.ga.crossover(parents), model.curr_generation)
        push!(model.curr_pop, entitydata)
    end
end

function mutate_population(model::GAmodel)
    for entity in model.curr_pop
        model.ga.mutate(entity.entity)
    end
end

end
