defmodule AgCollisions.Repo.Migrations.CreateCollisionsVehicleTypes do
  use Ecto.Migration

  def change do
    create table(:collisions_vehicle_types) do
      add :collision_uuid,
          references(
            :collisions,
            column: :uuid,
            type: :binary_id,
            on_delete: :delete_all
          ),
          null: false

      add :vehicle_type_id,
          references(:vehicle_types, on_delete: :delete_all),
          null: false

      timestamps(type: :utc_datetime)
    end

    create index(:collisions_vehicle_types, [:collision_uuid])
    create index(:collisions_vehicle_types, [:vehicle_type_id])
  end
end
