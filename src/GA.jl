
module GA

# -------

importall Base

export  Entity,
        GAmodel,

        freeze,
        run

# -------

abstract Entity

function isless(lhs::Entity, rhs::Entity)
    lhs.score < rhs.score
end

# -------

type EntityData
    entity
    generation::Int

    EntityData(entity, generation::Int) = new(entity, generation)
    EntityData(entity, model) = new(entity, model.gen_num)
end

isless(a::EntityData, b::EntityData) = (a.score < b.score)

# -------

type GAmodel
    initial_pop_size::Int
    gen_num::Int

    population::Array
    pop_data::Array{EntityData}
    freezer::Array{EntityData}

    rng::AbstractRNG

    ga

    GAmodel() = new(0, 1, Any[], EntityData[], EntityData[], MersenneTwister(time_ns()), nothing)
end

global _g_model

# -------

freeze(entity) = freeze(_g_model, entity)

function freeze(model::GAmodel, entity::EntityData)
    push!(model.freezer, entity)
    println("Freezing: ", entity)
end

function freeze(model::GAmodel, entity)
    entitydata = EntityData(entity, model.gen_num)
    freeze(model, entitydata)
end

function run(mdl::Module; initial_pop_size = 100)
    model = GAmodel()
    model.ga = mdl
    model.initial_pop_size = initial_pop_size

    run(model)
end

function run(model::GAmodel)
    reset_model(model)
    create_initial_population(model)

    while true
        evaluate_population(model)

        grouper = @task model.ga.group_entities(model.population)
        groupings = Any[]
        while !istaskdone(grouper)
            group = consume(grouper)
            group != nothing && push!(groupings, group)
        end

        if length(groupings) < 1
            break
        end

        crossover_population(model, groupings)
        mutate_population(model)
    end
end

# -------

function reset_model(model::GAmodel)
    global _g_model = model

    model.gen_num = 1
    empty!(model.population)
    empty!(model.pop_data)
    empty!(model.freezer)
end

function create_initial_population(model::GAmodel)
    for i = 1:model.initial_pop_size
        entity = model.ga.create_entity(i)

        push!(model.population, entity)
        push!(model.pop_data, EntityData(entity, model.gen_num))
    end
end

function internal_eval_entity(model::GAmodel, entity)
    entity.score = model.ga.eval_entity(entity)
    entity
end

function evaluate_population(model::GAmodel)
    model.population = pmap((entity)->internal_eval_entity(model, entity), model.population)
    sort!(model.population; rev = true)
end

function crossover_population(model::GAmodel, groupings)
    old_pop = model.population

    model.population = Any[]
    sizehint(model.population, length(old_pop))

    model.pop_data = EntityData[]
    sizehint(model.pop_data, length(old_pop))

    model.gen_num += 1

    for group in groupings
        parents = { old_pop[i] for i in group }
        entity = model.ga.crossover(parents)

        push!(model.population, entity)
        push!(model.pop_data, EntityData(model.ga.crossover(parents), model.gen_num))
    end
end

function mutate_population(model::GAmodel)
    for entity in model.population
        model.ga.mutate(entity)
    end
end

end
