defmodule AgCollisions.Vehicles.VehicleType do
  @moduledoc """
  Ecto schema for vehicle types involved in collisions.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "vehicle_types" do
    field :type, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(vehicle_type, attrs) do
    vehicle_type
    |> cast(attrs, [:id, :type])
    |> validate_required([:type])
  end
end
