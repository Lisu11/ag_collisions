defmodule AgCollisions.Repo.Migrations.CreateCollisions do
  use Ecto.Migration

  def change do
    create table(:collisions, primary_key: [name: :uuid, type: :binary_id]) do
      add :date, :naive_datetime
      add :district, :string
      add :severity, :string
      add :casualties, :integer
      add :weather, :string, null: true
      add :road_condition, :string, null: true
      add :light_condition, :string, null: true
      add :speed_limit, :integer

      timestamps(type: :utc_datetime)
    end

    create index(:collisions, [:severity, :date])
  end
end
