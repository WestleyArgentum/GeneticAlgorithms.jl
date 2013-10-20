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
The framework will look for a `create_entity` function and will use it to create an initial population.

```julia
type EqualityMonster
    abcde::Array
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
    # we want the expression `a + 2b + 3c + 4d + 5e - 42` to be as close to 0 as possible

    score = ent.abcde[1] + 2 * ent.abcde[2] + 3 * ent.abcde[3] + 4 * ent.abcde[4] + 5 * ent.abcde[5]

    abs(score - 42)
end
```

###Group Entities
Grouping entities operates on a population (an array of entities sorted by score) and will be run as a task and expected to emit groups of entities that will be passed into a crossover function. Group entitites also provides a nice way to terminate the GA; if you want to stop, simply produce no groups.

```julia
function group_entities(pop)
    if pop[1].score == 0
        return
    end

    # simple naive groupings that pair the best entitiy with every other
    for i in 1:length(population)
        produce([1, i])
    end
end
```

###Crossover


###Mutate
