#!/usr/bin/env iex

# NOTE: :rand.uniform(n) generates a random number in [1,n].
import Bitwise, only: [bxor: 2]

# The random seed to use.
# As we are only using one process, we do not need to retrieve and pass the sede aro
:rand.seed(:exsplus, {1, 2, 3})

# Set the value to use for an STS. Should be 1 (mod 6) or 3 (mod 6).
v = 7

# Module to work directly with triples.
defmodule Triples do
  #################
  # Sort a triple #
  #################
  # Sort the elements of a triple.
  def sort({a, b, c}) do
    x = min(a, min(b, c))
    z = max(a, max(b, c))
    y = bxor(a, bxor(b, bxor(c, bxor(x, z))))
    {x, y, z}
  end

  #####################################
  # Decompose a triple into its pairs #
  #####################################
  # Divide a triple into its consistuent pairs.
  def triples_to_pair({x, y, z}), do: {{x, y}, {x, z}, {y, z}}
end


defmodule RandomSTS do
  #####################################
  # Pick a random element from a list #
  #####################################
  # Given a nonempty list:
  # 1. Return a random element from it.
  def random_elem(list) when is_list(list) and length(list) > 0 do
    idx = :rand.uniform(length(list)) - 1
    Enum.at list, idx
  end


  ###################################################
  # Pick a random element from a list and delete it #
  ###################################################
  # Given a nonempty list:
  # 1. Extract an element from the list.
  # 2. Return the element and the list with the random element removed.
  defp random_elem_delete(list) when is_list(list) and length(list) > 0 do
    elem = random_elem list
    list = List.delete list, elem
    {elem, list}
  end


  ########################################################
  # Pick two random elements from a list and delete them #
  ########################################################
  # Given a list containing at least two elements:
  # 1. Extract two random elements from a list.
  # 2. Return the two random elements (in any order) and the list with the random elements removed.
  def two_random_elements(list) when length(list) >= 2 do
    {elem1, list} = random_elem_delete list
    {elem2, list} = random_elem_delete list
    {{elem1, elem2}, list}
  end
end


defmodule STS do
  #####################
  # Create the points #
  #####################
  # Create the set of points from [0,v).
  def create_points(v), do: Enum.to_list(0..v-1)


  #####################################
  # Create the initial set of triples #
  #####################################
  # Create the set of all possible triples.
  # TODO: Will we need this?
  def create_triples(v) do
    points = create_points(v)
    for a <- points,
        b <- points,
        a < b,
        c <- points,
        b < c, do: {a, b, c}
  end


  #########################################
  # Create the initial missing pairs list #
  #########################################
  # Create a map with entries a => [x | ax ]
  def create_missing_pair_map(v) do
    points = create_points(v)
    Enum.into(points, %{}, fn key ->
      value = Enum.filter(points, fn x -> x != key end)
      {key, value}
    end)
  end


  ###########################################################
  # Pick the keys of a missing pair list that are not empty #
  ###########################################################
  # Return a list of the keys [k] of mpm such that length(mpm[k]) > 0.
  # These are the elements that are still not in all pairs.
  def get_points_with_missing_pairs(mpm) when is_map(mpm) do
    for {key, value} <- mpm, not Enum.empty?(value), do: key
  end


  #####################################################
  # Check if the missing pair map is completely empty #
  #####################################################
  # This only happens if we have a complete STS.
  def no_missing_pairs(mpm) when is_map(mpm) do
    Enum.all? Map.values(mpm), &Enum.empty?/1
  end
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

# Operations
# 1. If there are no pairs missing, stop: no_missing_pairs
# 2. Otherwise pick a list with pairs.
