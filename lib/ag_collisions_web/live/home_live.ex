defmodule AgCollisionsWeb.HomeLive do
  use AgCollisionsWeb, :live_view

  alias AgCollisionsWeb.Live.Components.{CollisionData, CollisionStats, Filters}

  import CollisionStats,
    only: [collision_stats: 1]

  import Filters,
    only: [data_filters: 1]

  import CollisionData,
    only: [collision_data: 1]

  @impl true
  def handle_info({:filter, filter}, socket) do
    send_update(CollisionStats, id: "collision-stats", filter: filter)
    send_update(CollisionData, id: "collision-data", filter: filter)

    noreply(socket)
  end

  def handle_info({:all_collisions, 0}, socket) do
    send_update(CollisionData, id: "collision-data", all_collisions: 0)

    socket
    |> put_flash(:error, "NO collisions meeting the criteria")
    |> noreply()
  end

  def handle_info({:all_collisions, colls}, socket) do
    send_update(CollisionData, id: "collision-data", all_collisions: colls)

    socket
    |> clear_flash()
    |> noreply()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-4 p-2">
      <.data_filters
        on_filter_change={&on_filter_change/1}
        {assigns}
      />
      <.collision_stats
        id="collision-stats"
        on_stats_recomputed={&on_stats_recomputed/1}
        {assigns}
      />
      <.collision_data
        id="collision-data"
        {assigns}
      />
    </div>
    """
  end

  # -------------  PRIV --------------

  defp on_filter_change(filter) do
    send(self(), {:filter, filter})
  end

  defp on_stats_recomputed(stats) do
    send(self(), {:all_collisions, stats})
  end
end
