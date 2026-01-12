defmodule AgCollisionsWeb.Live.Components.CollisionData do
  @moduledoc """
  LiveComponent for displaying collision data in a grid and showing details of the selected collision.
  """
  use AgCollisionsWeb, :live_component

  alias AgCollisions.Collisions
  alias AgCollisions.Collisions.Collision

  attr :id, :string, required: true

  def collision_data(assigns) do
    ~H"""
    <.live_component
      module={__MODULE__}
      id={@id}
    />
    """
  end

  @impl true
  def mount(socket) do
    socket
    |> assign(selected: %Collision{vehicles: []})
    |> assign(filter: nil)
    |> assign(all_collisions: nil)
    |> ok()
  end

  @impl true
  def update(%{filter: filter}, socket) do
    socket
    |> assign(filter: filter)
    |> ok()
  end

  def update(%{all_collisions: colls}, socket) do
    socket
    |> assign(all_collisions: colls)
    |> push_event("refresh-grid", %{})
    |> ok()
  end

  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> ok()
  end

  @impl true
  def handle_event("row-selected", %{"uuid" => uuid}, socket) do
    selected = socket.assigns.data[uuid]

    socket
    |> assign(selected: selected)
    |> noreply()
  end

  def handle_event("get-rows", %{"endRow" => end_row, "startRow" => offset}, socket) do
    data =
      socket.assigns.filter
      |> Collisions.get_collisions(offset, end_row - offset)

    socket
    |> assign(data: Map.new(data, &{&1.uuid, &1}))
    |> reply(%{
      data: data,
      count: socket.assigns.all_collisions
    })
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section id={@id} class="flex flex-col gap-4">
      <div class="rounded-lg border border-white pt-4">
        <h2 class="text-white text-xl ml-4 mb-2">
          Collision Records
        </h2>
        <div
          id="myGrid"
          phx-hook="GridHook"
          phx-update="ignore"
          phx-target={@myself}
          style="width: 100%; height: 400px"
        >
        </div>
      </div>

      <div class="details border rounded-lg p-4 flex flex-col gap-4 bg-[#1f2836]">
        <span class="text-white text-xl">Selected Collision Details:</span>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-y-2 gap-x-8 ">
          <div class="flex flex-row  hover:scale-[1.05] justify-between gap-2">
            <span class="detail-key">Date:</span>
            <span class="detail-val">{@selected.date}</span>
          </div>
          <div class="flex flex-row  hover:scale-[1.05] justify-between gap-2">
            <span class="detail-key">Location:</span>
            <span class="detail-val">{@selected.district}</span>
          </div>
          <div class="flex flex-row hover:scale-[1.05] justify-between gap-2">
            <span class="detail-key">Severity:</span>
            <span class="detail-val">{@selected.severity}</span>
          </div>
          <div class="flex flex-row hover:scale-[1.05] justify-between gap-2">
            <span class="detail-key">Casualties:</span>
            <span class="detail-val">{@selected.casualties}</span>
          </div>
          <div class="flex flex-row hover:scale-[1.05] justify-between gap-2">
            <span class="detail-key">Weather:</span>
            <span class="detail-val">{@selected.weather}</span>
          </div>
          <div class="flex flex-row hover:scale-[1.05] justify-between gap-2">
            <span class="detail-key">Road:</span>
            <span class="detail-val">{@selected.road_condition}</span>
          </div>
          <div class="flex flex-row hover:scale-[1.05] justify-between gap-2">
            <span class="detail-key">Light:</span>
            <span class="detail-val">{@selected.light_condition}</span>
          </div>
          <div class="flex flex-row hover:scale-[1.05] justify-between gap-2">
            <span class="detail-key">Speed Limit:</span>
            <span class="detail-val">{@selected.speed_limit}</span>
          </div>
          <div class="flex flex-row hover:scale-[1.05] justify-between gap-2">
            <span class="detail-key">Vehicles:</span>
            <div class="detail-val vehicles-val flex flex-col">
              <span :for={vehicle <- @selected.vehicles}>
                {vehicle.type}
              </span>
            </div>
          </div>
        </div>
      </div>
    </section>
    """
  end
end
