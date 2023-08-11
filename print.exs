#!/usr/bin/env iex

defmodule ListExample do
  def print([]), do: :ok
  def print([head | tail]) do
    IO.puts head
    print tail
  end
end

list = [:storm, :sabretooth, :mystique]
ListExample.print list

### LIBRARIES ###
# Primary library to work with lists is Enum.
# Easier way than writing a module.
Enum.each list, &(IO.puts &1)

# Other examples of Enum.
list = [1, 2, 3, 4, 5]

IO.inspect Enum.filter list, &(&1 > 1)

# You can specify the initial value.
IO.inspect Enum.reduce list, &(&1 + &2)  # Uses 0 as default start
IO.inspect Enum.reduce list, &(&1 * &2)  # Uses 1 as default start

# Not quite sure what join does.
IO.inspect Enum.join list
IO.inspect Enum.join [[1, 2], [3, 4, 5], 6, [7], 8]

# Any
IO.inspect Enum.any? [1, 2, 3], &(&1 > 2)
IO.inspect Enum.all? [1, 2, 3], &(&1 > 2)

# Remember:
# ALL: forall x f(x) <-> not exist x not f(x)
# ANY: exist x f(x) <-> not forall x not f(x)
# NONE: forall x not f(x) <-> not exist x f(x) = not any
# NOTALL: exist x not f(x) <-> not forall x f(x) = not all
defmodule MyEnum do
  def all?(list, f), do: Enum.all?(list, f)
  def any?(list, f), do: Enum.any?(list, f)
  def none?(list, f), do: not any?(list, f)
  def notall?(list, f), do: not all?(list, f)
end

IO.puts "Checking list for conditions."
list = [0, 1, 3, 5, 7, 9, 11]

IO.inspect MyEnum.all? list, &(rem(&1, 2) == 1)
IO.inspect MyEnum.all? tl(list), &(rem(&1, 2) == 1)

IO.inspect MyEnum.any? list, &(&1 <= 0)
IO.inspect MyEnum.any? tl(list), &(&1 <= 0)

IO.inspect MyEnum.none? list, &(rem(&1, 2) == 0)
IO.inspect MyEnum.none? tl(list), &(rem(&1, 2) == 0)

IO.inspect MyEnum.notall? list, &(&1 < 10)
IO.inspect MyEnum.notall? (tl Enum.reverse list), &(&1 < 10)

IO.inspect Enum.zip [[1, 2], 3, [4], 5], [23, 20, 21]
System.halt 0
