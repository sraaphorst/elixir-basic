#!/usr/bin/env iex

defmodule Books do
  def author_str(author) do
    # Match to extract the information from the map.
    %{first: first, last: last} = author
    "#{first} #{last}"
  end

  def book_str(book) do
    # Match to extract the information from the map.
    %{title: title, author: author} = book
    "#{title} by #{author_str(author)}"
  end
end

### MAPS ###
# To avoid confusion with tuples, preface with %
language = %{ :name => "Elixir", :inventor => "Jose" }
IO.puts "#{language[:name]} was made by #{language[:inventor]}."

book = %{
  title: "Programming Elixir",
  author: %{first: "David", last: "Thomas"}
}

# Change an entry in book to make a new book.
new_book = put_in book.author.first, "Dave"

# To check if functions are exported and if something is a function.
IO.puts "Is Books.book_str exported? #{function_exported?(Books, :book_str, 1)}"

book_str_function = &Books.book_str/1
IO.puts "Is Books.book_str a function? #{is_function(book_str_function, 1)}"

IO.puts Books.book_str book
IO.puts book_str_function.(new_book)


### LISTS ###
# The primary variable-length structure in Elixir, implemented as linked lists.
# Cannot use random access.
list = [1, 2, 3]
IO.puts "is_list? #{is_list list}"

# We also have char lists. They MUST use single quotes or they are not lists.
char_list = 'abc'
IO.puts "#{char_list} is_list? #{is_list char_list}"

# Prepending to a list.
new_list = [0 | list]
one_entry_list = [0 | []]

# Some helpful lambdas for working with lists of Integer.
# There is already a length fn in Elixir that is optimized in C.
# Note that you have to pass in the function itself as a parameter to use
# it recursively, which you would not need to do with a module.
recursive_list_length_fn = fn
  [], acc, _ -> acc
  [_ | tail], acc, func -> func.(tail, acc + 1, func)
end

# Simplify calling by providing default parameters.
list_length_fn = fn(list) ->
  recursive_list_length_fn.(list, 0, recursive_list_length_fn)
end


recursive_list_str_fn = fn
  [], acc, _ -> "[#{String.trim_trailing(acc, ", ")}]"
  [a | tail], acc, func -> func.(tail, "#{acc}#{a}, ", func)
end
list_str_fn = fn(list) ->
  recursive_list_str_fn.(list, "", recursive_list_str_fn)
end

# Instead, using module:
defmodule Lists do
  def reverse(list), do: do_reverse(list, [])
  defp do_reverse([], acc), do: acc
  defp do_reverse([h|t], acc), do: do_reverse(t, [h | acc])

  def length(list), do: do_length(list, 0)
  defp do_length([], acc), do: acc
  defp do_length([_ | tail], acc), do: do_length(tail, acc + 1)

  # If the elements of a list can be converted to strings, this does so.
  def str(list), do: str(list, &"#{&1}")

  # Takes a stringify function that converts the elements of the list
  # to strings. Needed if the element conversion is not straightforward.
  def str(list, stringify), do: "[" <> str(list, "", stringify) <> "]"
  defp str([], acc, _), do: String.trim_trailing(acc, ", ")
  defp str([h|t], acc, stringify) do
    str(t, acc <> stringify.(h) <> ", ", stringify)
  end

  def zip(list1, list2), do: reverse(do_zip(list1, list2, []))
  defp do_zip([], _, acc), do: acc
  defp do_zip(_, [], acc), do: acc
  defp do_zip([x|xs], [y|ys], acc), do: do_zip(xs, ys, [[x,y]|acc])

  def map_list(list, map_fn), do: reverse(do_map_list(list, [], map_fn))
  defp do_map_list([], acc, _), do: acc
  # defp do_map_list([h|t], acc, map_fn), do: do_map_list(t, "#{acc}#{map_fn.(h)} ", map_fn)
  defp do_map_list([h|t], acc, map_fn), do: do_map_list(t, [map_fn.(h) | acc], map_fn)
end

# Call with the lambda and with the module call.
IO.puts "#{list_str_fn.(list)} has length #{list_length_fn.(list)}"
IO.puts "#{Lists.str(new_list)} has length #{Lists.length(new_list)}"

# Zip the two lists together and print.
zipped = Lists.zip(new_list, list)
str_zipped = Lists.map_list(zipped, &Lists.str/1)
IO.puts Lists.str(new_list) <> " and " <> Lists.str(list) <> " zipped are: " <> Lists.str(str_zipped)

System.halt 0
