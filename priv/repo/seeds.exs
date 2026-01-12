# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     AgCollisions.Repo.insert!(%AgCollisions.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
defmodule DataStreams do
  @collisions_csv "collision2017-2022.csv"
  @vehicles_csv "vehicle2017-2022.csv"
  @vehicle_types_csv "vehicle-index.csv"

  def get_collisions do
    __DIR__
    |> Path.join("seeds")
    |> Path.join(@collisions_csv)
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Stream.map(
      &%{
        uuid: id(&1["a_year"], &1["a_ref"]),
        date: date(&1["a_year"], &1["a_month"], &1["a_day"], &1["a_hour"], &1["a_min"]),
        district: &1["a_District"],
        severity: parse_severity(&1["a_type"]),
        casualties: String.to_integer(&1["a_cas"]),
        weather: nil_if_empty(&1["a_weat"]),
        road_condition: nil_if_empty(&1["a_roadsc"]),
        light_condition: nil_if_empty(&1["a_light"]),
        speed_limit: String.to_integer(&1["a_speed"])
      }
    )
  end

  def get_vehicle_types do
    __DIR__
    |> Path.join("seeds")
    |> Path.join(@vehicle_types_csv)
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Stream.filter(&(&1["col"] == "v_type"))
    |> Stream.map(
      &%{
        id: String.to_integer(&1["dummy"]),
        type: nil_if_empty(&1["name"])
      }
    )
  end

  def get_types_in_collisions do
    now = DateTime.utc_now()

    __DIR__
    |> Path.join("seeds")
    |> Path.join(@vehicles_csv)
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Stream.map(
      &%{
        inserted_at: now,
        updated_at: now,
        vehicle_type_id: parse_type(&1["v_type"]),
        collision_uuid: id(&1["a_year"], &1["a_ref"]) |> Ecto.UUID.dump!()
      }
    )
  end

  defp parse_severity(severity) do
    case String.downcase(severity) do
      "slight" <> _ -> :slight
      "serious" <> _ -> :serious
      "fatal" <> _ -> :fatal
      _ -> raise "Unknown severity: #{severity}"
    end
  end

  defp nil_if_empty(""), do: nil
  defp nil_if_empty(value), do: value

  defp date(year, month, day, hour, minute) do
    NaiveDateTime.new!(
      String.to_integer(year),
      String.to_integer(month),
      String.to_integer(day),
      String.to_integer(hour),
      String.to_integer(minute),
      0
    )
  end

  defp id(year, ref) do
    UUID.uuid5(:url, "#{year}-#{ref}")
  end

  defp parse_type(""), do: 0
  defp parse_type(" "), do: 0
  defp parse_type(type), do: String.to_integer(type)
end

for collision <- DataStreams.get_collisions() do
  AgCollisions.Collisions.create_collision!(collision)
end

for type <- DataStreams.get_vehicle_types() do
  AgCollisions.Vehicles.create_vehicle_type!(type)
end

DataStreams.get_types_in_collisions()
|> Stream.chunk_every(10_000)
|> Enum.each(fn chunk ->
  AgCollisions.Repo.insert_all("collisions_vehicle_types", chunk)
end)
