#!/usr/bin/env iex

### FOR COMPREHENSIONS ###
# Each has a:
# 1. generator step
# 2. filter step (can be omitted)
# 3. map step

# Very simple.
IO.inspect (for x <- [1, 2, 3], do: x)

# Multiple generators.
list = [0, 1, 2, 3, 4, 5]
triples = for x <- list, y <- list, z <- list, x < y and y < z, do: {x, y, z}

# Note that whitespace can be very finicky in Elixir.
triples = for x <- list,  # x <- list cannot be on a new line
              y <- list,
              x < y,
              z <- list,
              y < z do   # The do must be exactly here
                {x, y, z}
              end

IO.inspect triples

System.halt 0
