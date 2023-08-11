#!/usr/bin/env iex

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
  def random_elem(list, seed) when is_list(list) and length(list) > 0 do
    elem = Enum.at list, :rand.uniform(length(list)) - 1
    {elem, :rand.export_seed()}
  end

  #############################################
  # RANDOM ELEMENT FROM LIST AND DELETED LIST #
  #############################################
  # Given a list, get a random element from it, and then return the element and the list without the element.
  def random_elem_delete(list, seed) do
    {elem, seed} = random_elem list, seed
    {elem, (List.delete list, elem), seed}
  end

  def two_random_elements(list0, seed0) when length(list0) >= 2 do
    # Get the first element.
    {elem1, list1, seed1} = random_elem_delete(list0, seed0)

    # Get the second element.
    {elem2, list2, seed2} = random_elem_delete(list1, seed1)

    # Return the pair of elements in order, the uodated list, and the seed.
    {{min(elem1, elem2), max(elem1, elem2)}, list2, seed2}
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

{e1, seed} = RandomSTS.random_elem Map.keys(mpm), seed
IO.puts "Selected element #{e1}"
IO.puts "Seed is:"
IO.inspect seed

IO.puts "*** Two random elements ***"
{{e2, e3}, deleted_list, seed} = RandomSTS.two_random_elements mpm[e1], seed
IO.puts "Selected elements #{e2}, #{e3}"
IO.puts "List for #{e1} is now:"
IO.inspect deleted_list
IO.puts "Seed is:"
IO.inspect seed

IO.puts "*** Modifying mpm ***"
mpm = Map.put mpm, e1, deleted_list
IO.inspect mpm

System.halt 0
