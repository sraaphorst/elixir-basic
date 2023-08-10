#!/usr/bin/env iex

### Writing functions ###
# These are anonymous functions / lambdas.
inc = fn(x) -> x + 1 end
double_call_orig = fn(x, f) -> f.(f.(x)) end

double_call = &(&1.(&1.(&2)))
add = &(&1 + &2)

# Prints 5
IO.puts double_call.(inc, 3)

# Prints 7
IO.puts double_call.(inc, double_call.(inc, 3))


### Pipe notation ###
# Perhaps the most important operator in the language
dec = &(add.(&1, -1))

# Prints 11
IO.puts 10 |> inc.() |> inc.() |> dec.()


### Modules ###
defmodule Rectangle do
  def area({h, w}), do: h * w

  def perimeter({h, w}) do
    2 * (h + w)
  end
end

rect = {4, 7}
IO.puts "The area of rectangle #{inspect rect} is #{Rectangle.area(rect)}."


### do blocks ###
# Group lines of executable code together.
# Note the two different ways to declare functions.

defmodule Square do
  # Square.area/1
  def area({s}), do: Rectangle.area({s, s})

  # Square.area/2
  def area({w, h}) when w == h do
    Rectangle.area({w, h})
  end

  def perimeter({s}) do
    Rectangle.perimeter({s, s})
  end

  def perimeter({w, h}) when w == h do
    Rectangle.area({w, h})
  end
end

r = {3, 4}
IO.puts "The area of rectangle #{inspect r} is #{Rectangle.area r}."

s = {4}
IO.puts "The area of square #{inspect s} is #{Square.area(s)}."

s = {6, 6}
IO.puts "The perimeter of square #{inspect s} is #{Square.perimeter s}."

# This terminates the script so that we don't continue with the REPL.
System.halt 0
