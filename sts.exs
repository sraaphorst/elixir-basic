#!/usr/bin/env iex

# NOTE: :rand.uniform(n) generates a random number in [1,n].

# The random seed to use.
# As we are only using one process, we do not need to retrieve and pass the sede aro
:rand.seed(:exsplus, {1, 2, 3})

# Set the value to use for an STS. Should be 1 (mod 6) or 3 (mod 6).
v = 7

# Module to contain the randomness.
defmodule RandomSTS do
  ############################
  # RANDOM ELEMENT FROM LIST #
  ############################
  # Given a list, get a random element from it.
  def random_elem(list) when is_list(list) and length(list) > 0 do
    idx = :rand.uniform(length(list)) - 1
    Enum.at list, idx
  end

  #############################################
  # RANDOM ELEMENT FROM LIST AND DELETED LIST #
  #############################################
  # Given a list, get a random element from it, and then return the element and the list without the element.
  def random_elem_delete(list) do
    elem = random_elem list
    list = List.delete list, elem
    {elem, list}
  end

  def two_random_elements(list) when length(list) >= 2 do
    # Get the first element.
    {elem1, list} = random_elem_delete list

    # Get the second element.
    {elem2, list} = random_elem_delete list

    # Return the pair of elements in order, the uodated list, and the seed.
    {{elem1, elem2}, list}
  end
end


# Idea:
# 1. Create the set of triples.
# 2. Create the missing pairs lists.
defmodule STS do
  # Create the points.
  def create_points(v), do: Enum.to_list(0..v-1)

  # Create the set of triples.
  def create_triples(v) do
    points = create_points(v)
    for a <- points,
        b <- points,
        a < b,
        c <- points,
        b < c, do: {a, b, c}
  end

  # Create the initial missing pairs list.
  def create_missing_pair_map(v) do
    points = create_points(v)
    Enum.into(points, %{}, fn key ->
      value = Enum.filter(points, fn x -> x != key end)
      {key, value}
    end)
  end

  # Check if the missing pair map is completely empty.
  def no_missing_pairs(mpm) do
    Enum.all? Map.values(mpm), &Enum.empty?/1
  end

  # Given a triple, decompose it into pairs.
  def triples_to_pair({x, y, z}), do: {{x, y}, {x, z}, {y, z}}
end

mpm = STS.create_missing_pair_map(v)
IO.inspect mpm

IO.puts "*** Iteration 1 ***"

e1 = RandomSTS.random_elem Map.keys(mpm)
IO.puts "Selected element #{e1}"

IO.puts "*** Two random elements ***"
{{e2, e3}, deleted_list} = RandomSTS.two_random_elements mpm[e1]
IO.puts "Selected elements #{e2}, #{e3}"
IO.puts "List for #{e1} is now:"
IO.inspect deleted_list

IO.puts "*** Modifying mpm ***"
mpm = Map.put mpm, e1, deleted_list
IO.inspect mpm

IO.puts "*** Seed is now ***"
IO.inspect :rand.export_seed()

System.halt 0
