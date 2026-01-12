defmodule AgCollisions.Collisions do
  @moduledoc """
  The Collisions context.
  """

  import Ecto.Query, warn: false
  alias AgCollisions.Repo

  alias AgCollisions.Collisions.Collision
  alias AgCollisions.Collisions.Queries

  @type severity :: :slight | :serious | :fatal
  @type fatal_collisions_number :: integer()
  @type collisions_number :: integer()
  @type casulties_number :: integer()
  @type filter :: %{severities: list(severity()), from: integer(), to: integer()}

  @doc """
  Returns the list of collisions.

  ## Examples

      iex> list_collisions()
      [%Collision{}, ...]

  """
  def list_collisions do
    Repo.all(Collision)
  end

  @doc """
  Returns the number of fatal collisions based on the given filter.
  ## Examples

      iex> fatal_collisions(%{severities: [:fatal, :serious], from: 2015, to: 2020})
      42
  """
  @spec fatal_collisions(filter()) :: fatal_collisions_number()
  def fatal_collisions(filter) do
    if :fatal in filter.severities do
      Collision
      |> Queries.apply_filters(Map.put(filter, :severities, [:fatal]))
      |> Queries.count_collisions()
      |> Repo.one!()
    else
      0
    end
  end

  @doc """
  Returns the total number of collisions and casualties based on the given filter.

  ## Examples

      iex> total_collisions_and_casulties(%{severities: [:fatal, :serious], from: 2015, to: 2020})
      {100, 200}
  """
  @spec total_collisions_and_casulties(filter()) :: {collisions_number(), casulties_number()}
  def total_collisions_and_casulties(filter) do
    Collision
    |> Queries.apply_filters(filter)
    |> Queries.count_collisions_and_casulties()
    |> Repo.one!()
  end

  @doc """
  Returns a list of collisions grouped by months based on the given filter.

  ## Examples

      iex> collisions_by_months(%{severities: [:fatal, :serious], from: 2015, to: 2020})
      [{1, 10}, {2, 20}, ...]
  """
  @spec collisions_by_months(filter()) :: list({integer(), collisions_number()})
  def collisions_by_months(filter) do
    Collision
    |> Queries.apply_filters(filter)
    |> Queries.by_months()
    |> Repo.all()
  end

  @doc """
  Returns a list of all years for which collision data is available.

  ## Examples

      iex> all_years()
      [2015, 2016, 2017, ...]
  """
  @spec all_years() :: list(integer())
  def all_years do
    Collision
    |> Queries.select_years()
    |> Repo.all()
  end

  @doc """
  Returns a paginated list of collisions based on the given filter, offset, and limit.

  ## Examples

      iex> get_collisions(%{severities: [:fatal], from: 2015, to: 2020}, 0, 10)
      [%Collision{}, ...]

  """
  @spec get_collisions(filter(), integer(), integer()) :: list(Collision.t())
  def get_collisions(filter, offset \\ 0, limit \\ 100) do
    Collision
    |> Queries.apply_filters(filter)
    |> preload(:vehicles)
    |> offset(^offset)
    |> limit(^limit)
    |> Repo.all()
  end

  @doc """
  Gets a single collision.

  Raises `Ecto.NoResultsError` if the Collision does not exist.

  ## Examples

      iex> get_collision!(123)
      %Collision{}

      iex> get_collision!(456)
      ** (Ecto.NoResultsError)

  """
  def get_collision!(id), do: Repo.get!(Collision, id)

  @doc """
  Creates a collision.

  ## Examples

      iex> create_collision(%{field: value})
      %Collision{}

      iex> create_collision(%{field: bad_value})
      ** (Ecto.InvalidChangesetError)

  """
  def create_collision!(attrs) do
    %Collision{}
    |> Collision.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking collision changes.

  ## Examples

      iex> change_collision(collision)
      %Ecto.Changeset{data: %Collision{}}

  """
  def change_collision(%Collision{} = collision, attrs \\ %{}) do
    Collision.changeset(collision, attrs)
  end
end
