#GA.jl
[![Build Status](https://travis-ci.org/WestleyArgentum/GA.jl.png?branch=master)](https://travis-ci.org/WestleyArgentum/GA.jl)

This is a lightweight framework that simplifies the process of creating
genetic algorithms and running them in parallel.

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
The framework will look for a `create_entity` function and will use it to create an initial population. Your entity should inherit from the abstract `GA.Entity` and contain a member called `score`.

```julia
type EqualityMonster <: Entity
    abcde::Array
    score

    EqualityMonster() = new(Array(Int, 5), nothing)
    EqualityMonster(abcde) = new(abcde, nothing)
end

function create_entity(num)
    # for simplicity sake, let's limit the values for abcde to be integers in [-42, 42]
    EqualityMonster(rand(Int, 5) % 43)
end
```

###Create a Fitness Function
The framework will expect your fitness function to be called `eval_entity`. It should take in a single entity and return a score.

```julia
function eval_entity(ent)
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

Note: `isless(l::Entity, r::Entity)` will return `l.score < r.score`, but in our case entities with scores closer to 0 are doing better. So we should define a specialized `isless`.

```julia
function isless(lhs::EqualityMonster, rhs::EqualityMonster)
    abs(lhs.score) > abs(rhs.score)
end
```

###Group Entities
`group_entities` operates on a population (an array of entities sorted by score) and will be run as a task and expected to emit groups of entities that will be passed into a crossover function. `group_entitites` also provides a nice way to terminate the GA; if you want to stop, simply produce no groups.

```julia
function group_entities(pop)
    if pop[1].score == 0
        return
    end

    # simple naive groupings that pair the best entitiy with every other
    for i in 1:length(pop)
        produce([1, i])
    end
end
```

###Crossover
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

###Mutate
`mutate` operates on a single entity and is responsible for deciding whether or not to actually mutate.

```julia
function mutate(ent)
    # let's go crazy and mutate 20% of the time
    rand(Float64) < 0.8 && return

    rand_element = rand(Uint) % 5 + 1
    ent.abcde[rand_element] = rand(Int) % 43
end
```
