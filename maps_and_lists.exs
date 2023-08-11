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
  def reverse(list) when is_list(list), do: do_reverse(list, [])
  defp do_reverse([], acc), do: acc
  defp do_reverse([h|t], acc), do: do_reverse(t, [h | acc])

  def length(list) when is_list(list), do: do_length(list, 0)
  defp do_length([], acc), do: acc
  defp do_length([_ | tail], acc), do: do_length(tail, acc + 1)

  # Takes a stringify function that converts the elements of the list
  # to strings. Needed if the element conversion is not straightforward.
  # If no argument is given, just attempt a string conversion.
  # This makes str into a str/1 and str/2.
  def str(list, stringify \\ &"#{&1}") when is_list(list) and is_function(stringify, 1) do
    "[" <> str(list, "", stringify) <> "]"
  end
  defp str([], acc, _), do: String.trim_trailing(acc, ", ")
  defp str([h|t], acc, stringify) do
    str(t, acc <> stringify.(h) <> ", ", stringify)
  end

  def zip(list1, list2) when is_list(list1) and is_list(list2) do
    reverse(do_zip(list1, list2, []))
  end
  defp do_zip([], _, acc), do: acc
  defp do_zip(_, [], acc), do: acc
  defp do_zip([x|xs], [y|ys], acc), do: do_zip(xs, ys, [[x,y]|acc])

  # Partition a list into consecutive pairs of elements.
  # If there is an odd number, drop the last.
  def zip_in_pairs(list) when is_list(list), do: reverse(do_zip_in_pairs(list, []))
  defp do_zip_in_pairs([], acc), do: acc
  defp do_zip_in_pairs([_], acc), do: acc
  defp do_zip_in_pairs([h1, h2 | t], acc), do: do_zip_in_pairs(t, [[h1, h2] | acc])

  def map(list, map_fn) when is_list(list) and is_function(map_fn, 1) do
    reverse(do_map(list, [], map_fn))
  end
  defp do_map([], acc, _), do: acc
  defp do_map([h|t], acc, map_fn), do: do_map(t, [map_fn.(h) | acc], map_fn)
end

# Call with the lambda and with the module call.
IO.puts "#{list_str_fn.(list)} has length #{list_length_fn.(list)}"
IO.puts "#{Lists.str(new_list)} has length #{Lists.length(new_list)}"

# Zip the two lists together and print.
zipped = Lists.zip(new_list, list)
str_zipped = Lists.map(zipped, &Lists.str/1)
IO.puts Lists.str(new_list) <> " and " <> Lists.str(list) <> " zipped are: " <> Lists.str(str_zipped)

# Zip a list in pairs.
IO.inspect Lists.zip_in_pairs([0, 2, 1, 3, 4, 6, 5, 7, 8])

System.halt 0
