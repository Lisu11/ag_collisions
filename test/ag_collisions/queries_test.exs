defmodule AgCollisions.Collisions.QueriesTest do
  use AgCollisions.DataCase

  alias AgCollisions.Collisions.Queries
  alias AgCollisions.Collisions.Collision
  import AgCollisions.CollisionsFixtures

  describe "apply_filters/2" do
    test "applies severity and year filters to the query" do
      collision_fixture(%{severity: :fatal, date: ~N[2020-01-01 00:00:00]})
      collision_fixture(%{severity: :serious, date: ~N[2021-01-01 00:00:00]})
      collision_fixture(%{severity: :slight, date: ~N[2019-01-01 00:00:00]})

      filter = %{severities: [:fatal, :serious], from: 2020, to: 2021}
      query = Collision |> Queries.apply_filters(filter)

      assert Repo.all(query) |> Enum.map(& &1.severity) == [:fatal, :serious]
    end
  end

  describe "count_collisions/1" do
    test "counts the total number of collisions" do
      collision_fixture()
      collision_fixture()

      query = Queries.count_collisions()
      assert Repo.one(query) == 2
    end
  end

  describe "count_collisions_and_casulties/1" do
    test "counts the total number of collisions and casualties" do
      collision_fixture(%{casualties: 3})
      collision_fixture(%{casualties: 5})

      query = Queries.count_collisions_and_casulties()
      assert Repo.one(query) == {2, 8}
    end
  end

  describe "by_months/1" do
    test "groups collisions by months and counts them" do
      collision_fixture(%{date: ~N[2020-01-01 00:00:00]})
      collision_fixture(%{date: ~N[2020-01-15 00:00:00]})
      collision_fixture(%{date: ~N[2020-02-01 00:00:00]})

      query = Queries.by_months()
      assert Repo.all(query) == [{1, 2}, {2, 1}]
    end
  end

  describe "select_years/1" do
    test "selects distinct years from collision data" do
      collision_fixture(%{date: ~N[2020-01-01 00:00:00]})
      collision_fixture(%{date: ~N[2021-01-01 00:00:00]})

      query = Queries.select_years()
      assert Repo.all(query) == [2021, 2020]
    end
  end
end
