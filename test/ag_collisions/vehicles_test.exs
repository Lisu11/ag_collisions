defmodule AgCollisions.VehiclesTest do
  use AgCollisions.DataCase

  alias AgCollisions.Vehicles

  describe "vehicle_types" do
    alias AgCollisions.Vehicles.VehicleType

    import AgCollisions.VehiclesFixtures

    @invalid_attrs %{type: nil}

    test "list_vehicle_types/0 returns all vehicle_types" do
      vehicle_type = vehicle_type_fixture()
      assert Vehicles.list_vehicle_types() == [vehicle_type]
    end

    test "get_vehicle_type!/1 returns the vehicle_type with given id" do
      vehicle_type = vehicle_type_fixture()
      assert Vehicles.get_vehicle_type!(vehicle_type.id) == vehicle_type
    end

    test "create_vehicle_type/1 with valid data creates a vehicle_type" do
      valid_attrs = %{type: "some type"}

      assert %VehicleType{} = vehicle_type = Vehicles.create_vehicle_type!(valid_attrs)
      assert vehicle_type.type == "some type"
    end

    test "create_vehicle_type/1 with invalid data raises error changeset" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        Vehicles.create_vehicle_type!(@invalid_attrs)
      end
    end

    test "change_vehicle_type/1 returns a vehicle_type changeset" do
      vehicle_type = vehicle_type_fixture()
      assert %Ecto.Changeset{} = Vehicles.change_vehicle_type(vehicle_type)
    end
  end
end
