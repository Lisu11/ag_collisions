defmodule AgCollisionsWeb.Live.Components.Filters do
  @moduledoc """
  LiveComponent for filtering collision data by year and severity.
  """
  use AgCollisionsWeb, :live_component

  alias AgCollisions.Collisions
  alias AgCollisions.Collisions.Collision

  attr :on_filter_change, {:fun, 1}, required: true

  def data_filters(assigns) do
    ~H"""
    <.live_component
      module={__MODULE__}
      id="data-filters"
      on_filter_change={@on_filter_change}
    />
    """
  end

  @impl true
  def mount(socket) do
    [latest, latest2 | _] = years = Collisions.all_years()
    severities = Collision.severity_opts() |> Enum.map(&{&1, true})

    default_filter = %{
      from: latest2,
      to: latest,
      severities: severities
    }

    socket
    |> assign(year_opts: years)
    |> assign(ui_filter: default_filter)
    |> ok()
  end

  @impl true
  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> notify_parent()
    |> ok()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="filters grid md:grid-cols-2 gap-4 mb-4">
      <div class="flex flex-row gap-4 rounded-lg border p-2">
        <span class="text-[#9ca3af] text-lg  self-center pb-1">Severity:</span>
        <.input
          :for={{name, checked} <- @ui_filter.severities}
          type="checkbox"
          name={name}
          label={name}
          class="bg-blue-400"
          phx-click="checkbox-clicked"
          phx-value-checked={"#{!checked}"}
          phx-value-kind={name}
          phx-target={@myself}
          checked={checked}
        />
      </div>
      <div class="flex flex-row gap-4 rounded-lg border p-2">
        <span class="text-[#9ca3af] text-lg self-center">Year:</span>
        <.form for={to_form(%{})} class="flex flex-row">
          <.input
            type="select"
            name="from"
            value={@ui_filter.from}
            phx-change="select-year"
            phx-target={@myself}
            options={@year_opts}
          />
        </.form>
        <span class="text-[#9ca3af] text-lg self-center">to:</span>
        <.form for={to_form(%{})} class="flex flex-row">
          <.input
            type="select"
            name="to"
            value={@ui_filter.to}
            phx-change="select-year"
            phx-target={@myself}
            options={@year_opts}
          />
        </.form>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("checkbox-clicked", %{"kind" => severity}, socket) do
    filter =
      Map.update!(socket.assigns.ui_filter, :severities, fn s ->
        severity = String.to_existing_atom(severity)
        Keyword.update!(s, severity, &(not &1))
      end)

    filter_changed(socket, filter)
  end

  def handle_event("select-year", %{"from" => year}, socket) do
    year = String.to_integer(year)
    filter = Map.put(socket.assigns.ui_filter, :from, year)

    filter_changed(socket, filter)
  end

  def handle_event("select-year", %{"to" => year}, socket) do
    year = String.to_integer(year)
    filter = Map.put(socket.assigns.ui_filter, :to, year)

    filter_changed(socket, filter)
  end

  # -------------------   PRIVS  -----------------------

  defp filter_changed(socket, filter) do
    socket
    |> assign(ui_filter: filter)
    |> notify_parent()
    |> noreply()
  end

  defp db_filter_from_ui(ui_filter) do
    severities =
      Enum.flat_map(ui_filter.severities, fn
        {type, true} -> [type]
        _ -> []
      end)

    Map.put(ui_filter, :severities, severities)
  end

  def notify_parent(socket) do
    socket.assigns.ui_filter
    |> db_filter_from_ui()
    |> socket.assigns.on_filter_change.()

    socket
  end
end
