defmodule AgCollisions.CollisionsTest do
  use AgCollisions.DataCase

  alias AgCollisions.Collisions
  alias AgCollisions.Collisions.Collision
  import AgCollisions.CollisionsFixtures

  describe "collisions" do
    @invalid_attrs %{
      date: nil,
      severity: nil,
      district: nil,
      casualties: nil,
      weather: nil,
      road_condition: nil,
      light_condition: nil,
      speed_limit: nil
    }

    test "list_collisions/0 returns all collisions" do
      collision = collision_fixture()
      assert Collisions.list_collisions() == [collision]
    end

    test "get_collision!/1 returns the collision with given id" do
      collision = collision_fixture()
      assert Collisions.get_collision!(collision.uuid) == collision
    end

    test "create_collision!/1 with valid data creates a collision" do
      valid_attrs = %{
        date: ~N[2026-01-04 18:42:00],
        severity: :fatal,
        district: "some district",
        casualties: 42,
        weather: "some weather",
        road_condition: "some road_condition",
        light_condition: "some light_condition",
        speed_limit: 42
      }

      assert %Collision{} = collision = Collisions.create_collision!(valid_attrs)
      assert collision.date == ~N[2026-01-04 18:42:00]
      assert collision.severity == :fatal
      assert collision.district == "some district"
      assert collision.casualties == 42
      assert collision.weather == "some weather"
      assert collision.road_condition == "some road_condition"
      assert collision.light_condition == "some light_condition"
      assert collision.speed_limit == 42
    end

    test "create_collision!/1 with invalid data returns error changeset" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        Collisions.create_collision!(@invalid_attrs)
      end
    end

    test "change_collision/1 returns a collision changeset" do
      collision = collision_fixture()
      assert %Ecto.Changeset{} = Collisions.change_collision(collision)
    end
  end

  describe "severity_opts/0" do
    test "returns the list of severity options" do
      assert Collision.severity_opts() == [:slight, :serious, :fatal]
    end
  end

  describe "changeset/2" do
    @valid_attrs %{
      date: ~N[2026-01-12 12:00:00],
      district: "Central",
      severity: :serious,
      casualties: 3,
      weather: "Clear",
      road_condition: "Dry",
      light_condition: "Daylight",
      speed_limit: 50
    }

    @invalid_attrs %{
      date: nil,
      district: nil,
      severity: nil,
      casualties: nil,
      speed_limit: nil
    }

    test "returns a valid changeset with valid attributes" do
      changeset = Collision.changeset(%Collision{}, @valid_attrs)
      assert changeset.valid?
    end

    test "returns an invalid changeset with missing required attributes" do
      changeset = Collision.changeset(%Collision{}, @invalid_attrs)
      refute changeset.valid?

      assert %{
               date: ["can't be blank"],
               district: ["can't be blank"],
               severity: ["can't be blank"],
               casualties: ["can't be blank"],
               speed_limit: ["can't be blank"]
             } =
               errors_on(changeset)
    end

    test "validates required fields" do
      changeset = Collision.changeset(%Collision{}, Map.drop(@valid_attrs, [:date]))
      refute changeset.valid?
      assert %{date: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "fatal_collisions/1" do
    test "returns the number of fatal collisions based on the filter" do
      collision_fixture(%{severity: :fatal, date: ~N[2020-01-01 00:00:00]})
      collision_fixture(%{severity: :serious, date: ~N[2020-01-01 00:00:00]})

      filter = %{severities: [:fatal], from: 2019, to: 2021}
      assert Collisions.fatal_collisions(filter) == 1
    end

    test "returns 0 if no fatal collisions match the filter" do
      collision_fixture(%{severity: :serious, date: ~N[2020-01-01 00:00:00]})

      filter = %{severities: [:slight], from: 2019, to: 2021}
      assert Collisions.fatal_collisions(filter) == 0
    end
  end

  describe "total_collisions_and_casulties/1" do
    test "returns the total number of collisions and casualties based on the filter" do
      collision_fixture(%{severity: :fatal, casualties: 3, date: ~N[2020-01-01 00:00:00]})
      collision_fixture(%{severity: :serious, casualties: 2, date: ~N[2020-01-01 00:00:00]})

      filter = %{severities: [:fatal, :serious], from: 2019, to: 2021}
      assert Collisions.total_collisions_and_casulties(filter) == {2, 5}
    end
  end

  describe "collisions_by_months/1" do
    test "returns a list of collisions grouped by months based on the filter" do
      collision_fixture(%{severity: :fatal, date: ~N[2020-01-01 00:00:00]})
      collision_fixture(%{severity: :serious, date: ~N[2020-01-15 00:00:00]})
      collision_fixture(%{severity: :fatal, date: ~N[2020-02-01 00:00:00]})

      filter = %{severities: [:fatal, :serious], from: 2019, to: 2021}
      assert Collisions.collisions_by_months(filter) == [{1, 2}, {2, 1}]
    end
  end

  describe "all_years/0" do
    test "returns a list of all years for which collision data is available" do
      collision_fixture(%{date: ~N[2020-01-01 00:00:00]})
      collision_fixture(%{date: ~N[2021-01-01 00:00:00]})

      assert Collisions.all_years() == [2021, 2020]
    end
  end

  describe "get_collisions/3" do
    alias AgCollisions.Repo

    test "returns a paginated list of collisions based on the filter, offset, and limit" do
      collision1 =
        collision_fixture(%{severity: :fatal, date: ~N[2020-01-01 00:00:00]})
        |> Repo.preload(:vehicles)

      collision2 =
        collision_fixture(%{severity: :serious, date: ~N[2020-01-02 00:00:00]})
        |> Repo.preload(:vehicles)

      collision3 =
        collision_fixture(%{severity: :fatal, date: ~N[2020-01-03 00:00:00]})
        |> Repo.preload(:vehicles)

      filter = %{severities: [:fatal, :serious], from: 2019, to: 2021}
      assert Collisions.get_collisions(filter, 0, 2) == [collision1, collision2]
      assert Collisions.get_collisions(filter, 2, 2) == [collision3]

      filter = %{severities: [:fatal, :serious], from: 2022, to: 2021}
      assert Collisions.get_collisions(filter, 0, 2) == []
    end
  end

  describe "Jason.Encoder for Collision" do
    test "encodes collision struct to JSON" do
      collision = collision_fixture(%{severity: :fatal, date: ~N[2020-01-01 00:00:00]})

      json = Jason.encode!(collision)

      assert json =~ ~s("severity":"fatal")
      assert json =~ ~s("date":"2020-01-01T00:00:00")
      assert json =~ ~s("district":"some district")
      assert json =~ ~s("casualties":42)
    end
  end
end
