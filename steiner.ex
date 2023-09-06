#!/usr/bin/env elixir
# By Sebastian Raaphorst, 2023.
# A module to perform hill-climbing to find a Steiner triple system
# using functional programming.

defmodule SteinerTripleSystems do
  @spec generate(tuple, integer) :: [[integer]]
  def generate(seed, v) when is_integer(v) and rem(v, 6) in [1,3] do
    v |> create_missing_pairs_map |> generate([], seed)
  end

  @spec generate([[integer]], [[integer]], tuple) :: [[integer]]
  defp generate(missing_pairs, triples, seed) do
    if all_pairs_covered? missing_pairs do
      # Sort the triples
      triples |> Enum.map(&Enum.sort/1)
    else
      # Get a point missing a pair.
      candidates = for {key, value} <- missing_pairs, (not Enum.empty? value), do: key
      {x, seed} = candidates |> random_elem(seed)
      x_list = missing_pairs[x]

      # Get two random elements from the list of uncovered pairs with x and delete them
      # from the list with x.
      {y, seed} = x_list |> random_elem(seed)
      x_list = x_list |> List.delete(y)
      {z, seed} = x_list |> random_elem(seed)
      x_list = x_list |> List.delete(z)
      missing_pairs = missing_pairs |> Map.put(x, x_list)

      # Remove x from the lists for y and z.
      y_list = missing_pairs[y] |> List.delete(x)
      z_list = missing_pairs[z] |> List.delete(x)

      # Check if z is in y's list and y is in z's list, in which case, we can easily add the triple.
      if Enum.member?(y_list, z) and Enum.member?(z_list, y) do
        y_list = y_list |> List.delete(z)
        missing_pairs = missing_pairs |> Map.put(y, y_list)

        z_list = z_list |> List.delete(y)
        missing_pairs |> Map.put(z, z_list) |> generate([[x, y, z] | triples], seed)

      else
        # Otherwise, y and z already appear together in some triple with w.
        triple = triples |> Enum.find(nil, &triple_covers?(&1, y, z))
        triples = triples |> List.delete(triple)
        w = triple |> third_element(y, z)

        # Mark y and w as not being covered.
        y_list = [w | y_list]
        missing_pairs = missing_pairs |> Map.put(y, y_list)

        # Mark z and w as not being covered.
        z_list = [w | z_list]
        missing_pairs = missing_pairs |> Map.put(z, z_list)

        # Mark w and y and z as not being covered.
        w_list = [y, z | missing_pairs[w]]

        missing_pairs
        |> Map.put(w, w_list)
        |> generate([[x, y, z] | triples], seed)
      end
    end
  end

  # Create the total list of points [0,v).
  @spec points(integer) :: [integer]
  defp points(v), do: Enum.to_list(0..v-1)

  # Create the initial map of missing pairs.
  # Should be of the form, for example, for 7:
  # %{0 => [1, 2, 3, 4, 5, 6],
  #   1 => [0, 2, 3, 4, 5, 6],
  #   2 => [0, 1, 3, 4, 5, 6], etc.}
  @spec create_missing_pairs_map(integer) :: %{integer => [integer]}
  defp create_missing_pairs_map(v) do
    points = points(v)
    Enum.into points, %{}, &{&1, List.delete(points, &1)}
  end

  # Check if all pairs covered, i.e. we have a complete system.
  @spec all_pairs_covered?([[integer]]) :: boolean
  defp all_pairs_covered?(missing_pairs) do
    missing_pairs
    |> Map.values
    |> Enum.all?(&Enum.empty?/1)
  end

  # Get a random element from a list.
  @spec random_elem([integer], tuple) :: integer
  defp random_elem(list, seed) when is_list(list) and length(list) > 0 do
    {idx, seed} = list |> length |> :rand.uniform_s(seed)
    {Enum.at(list, idx - 1), seed}
  end

  # Determine if a triple covers a pair {y, z}.
  @spec triple_covers?([[integer]], integer, integer) :: boolean
  defp triple_covers?(triple, y, z) do
    Enum.member?(triple, y) and Enum.member?(triple, z)
  end

  # Given a triple and two of its elements, x and y, find the third element.
  @spec third_element([[integer]], integer, integer) :: integer
  defp third_element(triple, y, z), do: Enum.find(triple, &(&1 != y and &1 != z))
end

n = case (System.argv |> List.first) do
  nil -> IO.puts("Usage: steiner.ex v") ; System.halt(1)
  str -> {num, _} = str |> Integer.parse ; num
end

:rand.seed(:exsplus, {1, 2, 3})
|> SteinerTripleSystems.generate(n)
|> Enum.each(&IO.inspect(&1, charlists: :as_lists))

System.halt 0
