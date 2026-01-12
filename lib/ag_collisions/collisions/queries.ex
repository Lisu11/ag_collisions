defmodule AgCollisions.Collisions.Queries do
  @moduledoc """
  Provides query building functions for collision data.
  """
  import Ecto.Query, warn: false
  alias AgCollisions.Collisions.Collision

  @doc """
  Returns the base query for the `Collision` schema.
  """
  defmacro base, do: Collision

  @doc """
  Applies filters to the query based on the provided filter map.

  ## Parameters
    - `query`: The base query to apply filters to.
    - `filter`: A map containing `:severities`, `:from`, and `:to` keys.

  ## Examples

      iex> apply_filters(Collision, %{severities: [:fatal], from: 2015, to: 2020})
      #Ecto.Query<...>
  """
  def apply_filters(query, filter) do
    %{severities: severities, from: year_from, to: year_to} = filter

    query
    |> where([c], c.severity in ^severities)
    |> where([c], fragment("DATE_PART('year', ?)", c.date) <= ^year_to)
    |> where([c], fragment("DATE_PART('year', ?)", c.date) >= ^year_from)
  end

  @doc """
  Counts the total number of collisions in the query.

  ## Parameters
    - `query`: The query to count collisions from.

  ## Examples

      iex> count_collisions(Collision)
      #Ecto.Query<...>
  """
  def count_collisions(query \\ base()) do
    query
    |> select([c], count(c.uuid))
  end

  @doc """
  Counts the total number of collisions and casualties in the query.

  ## Parameters
    - `query`: The query to count collisions and casualties from.

  ## Examples

      iex> count_collisions_and_casulties(Collision)
      #Ecto.Query<...>
  """
  def count_collisions_and_casulties(query \\ base()) do
    query
    |> select([c], {count(c.uuid), sum(c.casualties)})
  end

  @doc """
  Groups collisions by months and counts the number of collisions for each month.

  ## Parameters
    - `query`: The query to group collisions by months.

  ## Examples

      iex> by_months(Collision)
      #Ecto.Query<...>
  """
  def by_months(query \\ base()) do
    query
    |> group_by([c], selected_as(:month))
    |> select(
      [c],
      {selected_as(fragment("DATE_PART('month', ?)::integer", c.date), :month), count(c.uuid)}
    )
  end

  @doc """
  Selects distinct years from the collision data.

  ## Parameters
    - `query`: The query to select years from.

  ## Examples

      iex> select_years(Collision)
      #Ecto.Query<...>
  """
  def select_years(query \\ base()) do
    query
    |> group_by([c], selected_as(:year))
    |> order_by([c], desc: selected_as(:year))
    |> select([c], selected_as(fragment("DATE_PART('year', ?)::integer", c.date), :year))
  end
end
