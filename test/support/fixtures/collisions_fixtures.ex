defmodule AgCollisions.CollisionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AgCollisions.Collisions` context.
  """

  @doc """
  Generate a collision.
  """
  def collision_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      casualties: 42,
      date: ~N[2026-01-04 18:42:00],
      district: "some district",
      light_condition: "some light_condition",
      road_condition: "some road_condition",
      severity: :fatal,
      speed_limit: 42,
      weather: "some weather"
    })
    |> AgCollisions.Collisions.create_collision!()
  end
end
