defmodule AgCollisions.Vehicles do
  @moduledoc """
  The Vehicles context.
  """

  import Ecto.Query, warn: false
  alias AgCollisions.Repo

  alias AgCollisions.Vehicles.VehicleType

  @doc """
  Returns the list of vehicle_types.

  ## Examples

      iex> list_vehicle_types()
      [%VehicleType{}, ...]

  """
  def list_vehicle_types do
    Repo.all(VehicleType)
  end

  @doc """
  Gets a single vehicle_type.

  Raises `Ecto.NoResultsError` if the Vehicle type does not exist.

  ## Examples

      iex> get_vehicle_type!(123)
      %VehicleType{}

      iex> get_vehicle_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_vehicle_type!(id), do: Repo.get!(VehicleType, id)

  @doc """
  Creates a vehicle_type.

  ## Examples

      iex> create_vehicle_type(%{field: value})
      {:ok, %VehicleType{}}

      iex> create_vehicle_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_vehicle_type!(attrs) do
    %VehicleType{}
    |> VehicleType.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking vehicle_type changes.

  ## Examples

      iex> change_vehicle_type(vehicle_type)
      %Ecto.Changeset{data: %VehicleType{}}

  """
  def change_vehicle_type(%VehicleType{} = vehicle_type, attrs \\ %{}) do
    VehicleType.changeset(vehicle_type, attrs)
  end
end
