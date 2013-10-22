#GeneticAlgorithms.jl

[![Build Status](https://travis-ci.org/WestleyArgentum/GeneticAlgorithms.jl.png?branch=master)](https://travis-ci.org/WestleyArgentum/GeneticAlgorithms.jl)

####This is a lightweight framework that simplifies the process of creating genetic algorithms and running them in parallel.

##Basic Usage
###What's your problem???
Let's say you've got a simple equality `a + 2b + 3c + 4d + 5e = 42` that you'd like come up with a solution for.

###Create a Module
Start by creating a file and a module for your ga. Your module will be loaded into the framework and things inside it will be used to run your algroithm.

```julia
module equalityga
    # implement the GA interface inside here
end
```

###Define an Entity
Your entity should inherit from the abstract `GeneticAlgorithms.Entity`. The framework will look for a `create_entity` function and will use it to create an initial population.

```julia
type EqualityMonster <: Entity
    abcde::Array
    fitness

    EqualityMonster() = new(Array(Int, 5), nothing)
    EqualityMonster(abcde) = new(abcde, nothing)
end

function create_entity(num)
    # for simplicity sake, let's limit the values for abcde to be integers in [-42, 42]
    EqualityMonster(rand(Int, 5) % 43)
end
```

Note that `EqualityMonster` has a field `fitness`. By default this field will be used by the framework to store the entities calculated fitness, so that you have access to it elsewhere in your GA. If you'd like to change the behavior you can overload `fitness!(entity::EqualityMonster, score)`.

###Create a Fitness Function
The framework will expect a `fitness` function. It should take in a single entity and return a fitness score.

```julia
function fitness(ent)
    # we want the expression `a + 2b + 3c + 4d + 5e - 42`
    # to be as close to 0 as possible
    score = ent.abcde[1] +
            2 * ent.abcde[2] +
            3 * ent.abcde[3] +
            4 * ent.abcde[4] +
            5 * ent.abcde[5]

    abs(score - 42)
end
```

Note that `isless(l::Entity, r::Entity)` will return `l.fitness < r.fitness`, but that in this case entities with scores closer to 0 are doing better. So we should define a specialized `isless`.

```julia
function isless(lhs::EqualityMonster, rhs::EqualityMonster)
    abs(lhs.fitness) > abs(rhs.fitness)
end
```

###Group Entities
`group_entities` operates on a population (an array of entities sorted by score) and will be run as a task and expected to emit groups of entities that will be passed into a crossover function. `group_entitites` also provides a nice way to terminate the GA; if you want to stop, simply produce no groups.

```julia
function group_entities(pop)
    if pop[1].fitness == 0
        return
    end

    # simple naive groupings that pair the best entitiy with every other
    for i in 1:length(pop)
        produce([1, i])
    end
end
```

###Define Crossover
`crossover` should take a group of parents and produce a new child entity. In our case we'll just grab properties from random parents.

```julia
function crossover(group)
    child = EqualityMonster()

    # grab each element from a random parent
    num_parents = length(group)
    for i in 1:length(group[1].abcde)
        parent = (rand(Uint) % num_parents) + 1
        child.abcde[i] = group[parent].abcde[i]
    end

    child
end
```

###Define Mutation
`mutate` operates on a single entity and is responsible for deciding whether or not to actually mutate.

```julia
function mutate(ent)
    # let's go crazy and mutate 20% of the time
    rand(Float64) < 0.8 && return

    rand_element = rand(Uint) % 5 + 1
    ent.abcde[rand_element] = rand(Int) % 43
end
```

###Run your GA!

```julia
using GeneticAlgorithms
require("GeneticAlgorithms/test/equalityga.jl")

model = runga(equalityga; initial_pop_size = 16)

model.population  # the the latest population when the GA exited
```
