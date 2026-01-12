defmodule AgCollisions.Repo do
  use Ecto.Repo,
    otp_app: :ag_collisions,
    adapter: Ecto.Adapters.Postgres
end
