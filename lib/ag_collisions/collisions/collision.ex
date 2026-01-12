defmodule AgCollisions.Collisions.Collision do
  @moduledoc """
  Ecto schema for collision records.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias AgCollisions.Vehicles

  @severities [:slight, :serious, :fatal]
  def severity_opts, do: @severities

  @primary_key {:uuid, :binary_id, autogenerate: true}
  schema "collisions" do
    field :date, :naive_datetime
    field :severity, Ecto.Enum, values: @severities
    field :district, :string
    field :casualties, :integer
    field :weather, :string
    field :road_condition, :string
    field :light_condition, :string
    field :speed_limit, :integer

    many_to_many :vehicles, Vehicles.VehicleType,
      join_keys: [collision_uuid: :uuid, vehicle_type_id: :id],
      join_through: "collisions_vehicle_types"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(collision, attrs) do
    collision
    |> cast(attrs, [
      :uuid,
      :date,
      :district,
      :severity,
      :casualties,
      :weather,
      :road_condition,
      :light_condition,
      :speed_limit
    ])
    |> validate_required([:date, :district, :severity, :casualties, :speed_limit])
  end
end

defimpl Jason.Encoder, for: AgCollisions.Collisions.Collision do
  def encode(collision, opts) do
    collision
    |> Map.take([
      :uuid,
      :date,
      :severity,
      :district,
      :casualties,
      :weather,
      :road_condition
    ])
    |> Enum.map(fn
      {:road_condition, conditions} -> {:road, conditions}
      otherwise -> otherwise
    end)
    |> Enum.into(%{})
    |> Jason.Encode.map(opts)
  end
end
