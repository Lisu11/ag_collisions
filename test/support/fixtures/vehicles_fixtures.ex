defmodule AgCollisions.VehiclesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AgCollisions.Vehicles` context.
  """

  @doc """
  Generate a vehicle_type.
  """
  def vehicle_type_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      type: "some type"
    })
    |> AgCollisions.Vehicles.create_vehicle_type!()
  end
end
