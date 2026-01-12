defmodule AgCollisionsWeb.Live.Components.CollisionStats do
  @moduledoc """
  LiveComponent for displaying collision statistics and a chart.
  """
  use AgCollisionsWeb, :live_component

  alias AgCollisions.Collisions

  @months [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ]

  attr :id, :string, required: true
  attr :on_stats_recomputed, {:fun, 1}, required: true

  def collision_stats(assigns) do
    ~H"""
    <.live_component
      module={__MODULE__}
      id={@id}
      on_stats_recomputed={@on_stats_recomputed}
    />
    """
  end

  @impl true
  def mount(socket) do
    socket
    |> assign(total_collisions: "-")
    |> assign(fatal_collisions: "-")
    |> assign(total_casualties: "-")
    |> assign(most_dangerous_month: "-")
    |> assign(chart_data: [])
    |> ok()
  end

  @impl true
  def update(%{filter: filter} = assigns, socket) do
    socket
    |> assign(assigns)
    |> assign_stats(filter)
    |> assign_chart_data()
    |> notify_parent()
    |> ok()
  end

  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> ok()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section id={@id} class="flex flex-col gap-4 mb-4">
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div class="grid stats-card border border-gray-200 p-4 rounded-lg hover:scale-[1.05]">
          <span class="text-gray-400">
            Total Collisions
          </span>
          <span class="text-white justify-self-center  text-lg">
            {@total_collisions}
          </span>
        </div>
        <div class="grid stats-card border border-gray-200 p-4 rounded-lg hover:scale-[1.05]">
          <span class="text-gray-400">
            Fatal Collisions
          </span>
          <span class="text-white justify-self-center  text-lg">
            {@fatal_collisions}
          </span>
        </div>
        <div class="grid stats-card border border-gray-200 p-4 rounded-lg hover:scale-[1.05]">
          <span class="text-gray-400">
            Total Casulties
          </span>
          <span class="text-white justify-self-center  text-lg">
            {@total_casualties}
          </span>
        </div>
        <div class="grid stats-card border border-gray-200 p-4 rounded-lg hover:scale-[1.05]">
          <span class="text-gray-400">
            Riskiest Month
          </span>
          <span class="text-white justify-self-center text-lg">
            {@most_dangerous_month}
          </span>
        </div>
      </div>
      <div class="layout-container">
        <div
          id="myChart"
          phx-hook="ChartHook"
          phx-update="ignore"
          data-chart-data={Jason.encode!(@chart_data)}
          class="w-full h-[400px] rounded-lg border"
        >
        </div>
      </div>
    </section>
    """
  end

  defp assign_stats(socket, filter) do
    fatal = Collisions.fatal_collisions(filter)
    {cols, cas} = Collisions.total_collisions_and_casulties(filter)
    by_months = Collisions.collisions_by_months(filter)
    month = most_dangerous_month(by_months)

    socket
    |> assign(total_collisions: cols)
    |> assign(fatal_collisions: fatal)
    |> assign(total_casualties: cas)
    |> assign(most_dangerous_month: month)
    |> assign(collisions_by_months: by_months)
  end

  defp assign_chart_data(socket) do
    data =
      for {month, collisions} <- socket.assigns.collisions_by_months do
        month =
          @months
          |> Enum.at(month - 1)
          |> String.slice(0, 3)

        %{month: month, collisions: collisions}
      end

    assign(socket, chart_data: data)
  end

  defp most_dangerous_month([]), do: "-"

  defp most_dangerous_month(by_months) do
    by_months
    |> Enum.max_by(&elem(&1, 1))
    |> elem(0)
    |> then(&Enum.at(@months, &1 - 1))
  end

  defp notify_parent(%{assigns: assigns} = socket) do
    assigns.total_collisions
    |> assigns.on_stats_recomputed.()

    socket
  end
end
