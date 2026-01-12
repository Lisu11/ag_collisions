defmodule AgCollisionsWeb.HomeLiveTest do
  use AgCollisionsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import AgCollisions.CollisionsFixtures

  describe "HomeLive" do
    setup do
      collision_fixture(%{severity: :fatal, date: ~N[2020-01-01 00:00:00]})
      collision_fixture(%{severity: :serious, date: ~N[2021-01-01 00:00:00]})

      :ok
    end

    test "renders the live view with initial state", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      assert html =~ "collision-stats"
      assert html =~ "collision-data"
      assert html =~ "data-filters"
    end

    test "updates collision stats and data on filter change", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      filter = %{severities: [:fatal, :serious], from: 2020, to: 2021}
      send(view.pid, {:filter, filter})
      AgCollisions.Collisions.collisions_by_months(filter)

      chart_html =
        view
        |> element(~s{#myChart[data-chart-data]})
        |> render()

      assert chart_html =~
               "data-chart-data=\"[{&quot;month&quot;:&quot;Jan&quot;,&quot;collisions&quot;:2}]\""

      filter = %{severities: [:fatal, :serious], from: 2021, to: 2021}
      send(view.pid, {:filter, filter})

      AgCollisions.Collisions.collisions_by_months(filter)

      chart_html =
        view
        |> element(~s{#myChart[data-chart-data]})
        |> render()

      assert chart_html =~
               "data-chart-data=\"[{&quot;month&quot;:&quot;Jan&quot;,&quot;collisions&quot;:1}]\""
    end

    test "renders nested live components and handles checkbox click with chart data change", %{
      conn: conn
    } do
      {:ok, view, _html} = live(conn, "/")

      assert has_element?(view, "#data-filters")
      assert has_element?(view, "#collision-stats")
      assert has_element?(view, "#collision-data")

      chart_html =
        view
        |> element(~s{#myChart[data-chart-data]})
        |> render()

      assert chart_html =~
               "data-chart-data=\"[{&quot;month&quot;:&quot;Jan&quot;,&quot;collisions&quot;:2}]\""

      checkbox = element(view, "#data-filters input[type='checkbox'][name='fatal']")
      assert checkbox

      render_click(checkbox)
      assert render(view) =~ "collision-stats"

      chart_html =
        view
        |> element(~s{#myChart[data-chart-data]})
        |> render()

      assert chart_html =~
               "data-chart-data=\"[{&quot;month&quot;:&quot;Jan&quot;,&quot;collisions&quot;:1}]\""
    end

    test "handles year selection by change in chart data", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      assert has_element?(view, "#data-filters select[name='from']")
      assert has_element?(view, "#data-filters select[name='to']")

      chart_html =
        view
        |> element(~s{#myChart[data-chart-data]})
        |> render()

      assert chart_html =~
               "data-chart-data=\"[{&quot;month&quot;:&quot;Jan&quot;,&quot;collisions&quot;:2}]\""

      from_select = element(view, "#data-filters select[name='from']")
      to_select = element(view, "#data-filters select[name='to']")

      render_change(from_select, %{"from" => "2020"})
      render_change(to_select, %{"to" => "2020"})

      assert render(view) =~ "collision-stats"

      chart_html =
        view
        |> element(~s{#myChart[data-chart-data]})
        |> render()

      assert chart_html =~
               "data-chart-data=\"[{&quot;month&quot;:&quot;Jan&quot;,&quot;collisions&quot;:1}]\""
    end
  end
end
