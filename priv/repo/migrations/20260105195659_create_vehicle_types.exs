defmodule AgCollisions.Repo.Migrations.CreateVehicleTypes do
  use Ecto.Migration

  def change do
    create table(:vehicle_types) do
      add :type, :string, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
