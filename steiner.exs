#!/usr/bin/env iex

# The random seed to use.
# As we are only using one process, we do not need to retrieve and pass the sede aro
:rand.seed(:exsplus, {1, 2, 3})

defmodule SteinerTripleSystems do
  def generate(v) when is_integer(v) and (rem(v, 6) == 1 or rem(v, 6) == 3) do
    missing_pairs = create_missing_pairs_map v
    generate [], missing_pairs
  end

  def generate(triples, missing_pairs) do
    if all_pairs_covered? missing_pairs do
      # triples
      # Sort the triples
      for triple <- triples, do: Enum.sort(triple)
    else
      # Get a point missing a pair.
      x = missing_pairs |> Map.keys |> random_elem
      x_list = missing_pairs[x]

      # Get two random elements from the list of uncovered pairs with x and delete them
      # from the list with x.
      y = random_elem x_list
      x_list = List.delete x_list, y
      z = random_elem x_list
      x_list = List.delete x_list, z
      missing_pairs = Map.put missing_pairs, x, x_list

      # Remove x from the lists for y and z.
      y_list = List.delete missing_pairs[y], x
      z_list = List.delete missing_pairs[z], x

      # Check if z is in y's list and y is in z's list, in which case, we can easily add the triple.
      if Enum.member?(y_list, z) and Enum.member?(z_list, y) do
        y_list = List.delete y_list, z
        missing_pairs = Map.put missing_pairs, y, y_list

        z_list = List.delete z_list, y
        missing_pairs = Map.put missing_pairs, z, z_list

        generate [[x, y, z] | triples], missing_pairs

      else
        # Otherwise, y and z already appear together in some triple with w.
        triple = Enum.find triples, nil, &triple_contains?(&1, y, z)
        triples = List.delete triples, triple
        w = third_element triple, y, z

        # Mark y and w as not being covered.
        y_list = [w | y_list]
        missing_pairs = Map.put missing_pairs, y, y_list

        # Mark z and w as not being covered.
        z_list = [w | z_list]
        missing_pairs = Map.put missing_pairs, z, z_list

        # Mark w and y and z as not being covered.
        w_list = [y, z | missing_pairs[w]]
        missing_pairs = Map.put missing_pairs, w, w_list

        generate [[x, y, z] | triples], missing_pairs
      end
    end
  end

  # Create the total list of points [0,v).
  def points(v), do: Enum.to_list(0..v-1)

  # Create the initial map of missing pairs.
  # Should be of the form, for example, for 7:
  # %{0 => [1, 2, 3, 4, 5, 6],
  #   1 => [0, 2, 3, 4, 5, 6],
  #   2 => [0, 1, 3, 4, 5, 6], etc.}
  def create_missing_pairs_map(v) do
    points = points(v)
    Enum.into(points, %{}, fn key ->
      value = Enum.filter(points, fn x -> x != key end)
      {key, value}
    end)
  end

  # Check if all pairs covered.
  def all_pairs_covered?(missing_pairs) do
    Enum.all? Map.values(missing_pairs), &Enum.empty?/1
  end

  # Get the elements with missing pairs.
  def missing_pairs(missing_pairs) do
    for {key, value} <- missing_pairs, not Enum.empty?(value), do: key
  end

  # Get a random element from a list.
  def random_elem(list) when is_list(list) and length(list) > 0 do
    idx = :rand.uniform(length(list)) - 1
    Enum.at list, idx
  end

  def triple_contains?(triple, y, z) do
    Enum.member?(triple, y) and Enum.member?(triple, z)
  end

  def third_element([w, y, z], y, z), do: w
  def third_element([w, z, y], y, z), do: w
  def third_element([y, w, z], y, z), do: w
  def third_element([z, w, y], y, z), do: w
  def third_element([y, z, w], y, z), do: w
  def third_element([z, y, w], y, z), do: w
end

triples = SteinerTripleSystems.generate(7)
IO.inspect triples

System.halt 0
