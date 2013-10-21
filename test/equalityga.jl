

module equalityga

type EqualityMonster
    abcde::Array
    score

    EqualityMonster() = new(Array(Int, 5), nothing)
    EqualityMonster(abcde) = new(abcde, nothing)
end

function create_entity(num)
    # for simplicity sake, let's limit the values for abcde to be integers in [-42, 42]
    EqualityMonster(rand(Int, 5) % 43)
end

function eval_entity(ent)
    # we want the expression `a + 2b + 3c + 4d + 5e - 42` to be as close to 0 as possible
    score = ent.abcde[1] + 2 * ent.abcde[2] + 3 * ent.abcde[3] + 4 * ent.abcde[4] + 5 * ent.abcde[5]

    println(score - 42)

    -abs(score - 42)
end

function group_entities(pop)
    if pop[1].score == 0
        return
    end

    println("BEST: ", pop[1])

    # simple naive groupings that pair the best entitiy with every other
    for i in 1:length(pop)
        produce([1, i])
    end
end

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

function mutate(ent)
    # let's go crazy and mutate 20% of the time
    rand(Float64) < 0.8 && return

    rand_element = rand(Uint) % 5 + 1
    ent.abcde[rand_element] = rand(Int) % 43
end

end