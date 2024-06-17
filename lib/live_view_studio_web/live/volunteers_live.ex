defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  alias LiveViewStudioWeb.VolunteerFormComponent

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Volunteers.subscribe()
    end

    volunteers = Volunteers.list_volunteers()

    socket =
      socket
      |> stream(:volunteers, volunteers)
      |> assign(:count, length(volunteers))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>
    <div id="volunteer-checkin">
      <.live_component
        module={VolunteerFormComponent}
        id={:new}
        count={@count}
      />
      <div id="volunteers" phx-update="stream">
        <.volunteer
          :for={{volunteer_id, volunteer} <- @streams.volunteers}
          volunteer={volunteer}
          id={volunteer_id}
        />
      </div>
    </div>
    """
  end

  def handle_event("delete", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)
    {:ok, _} = Volunteers.delete_volunteer(volunteer)

    {:noreply, socket}
  end

  def handle_event("toggle-status", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)

    {:ok, _volunteer} =
      Volunteers.update_volunteer(volunteer, %{checked_out: !volunteer.checked_out})

    {:noreply, socket}
  end

  def handle_info({:volunteer_created, volunteer}, socket) do
    socket = stream_insert(socket, :volunteers, volunteer, at: 0)
    socket = update(socket, :count, &(&1 + 1))
    {:noreply, socket}
  end

  def handle_info({:volunteer_updated, volunteer}, socket) do
    socket = stream_insert(socket, :volunteers, volunteer)
    {:noreply, socket}
  end

  def handle_info({:volunteer_deleted, volunteer}, socket) do
    socket = update(socket, :count, &(&1 - 1))
    socket = stream_delete(socket, :volunteers, volunteer)
    {:noreply, socket}
  end

  def volunteer(assigns) do
    ~H"""
    <div
      class={"volunteer #{if @volunteer.checked_out, do: "out"}"}
      id={@id}
    >
      <div class="name">
        <%= @volunteer.name %>
      </div>
      <div class="phone">
        <%= @volunteer.phone %>
      </div>
      <div class="status">
        <button phx-click={toggle_volunteer_status(@volunteer, @id)}>
          <%= if @volunteer.checked_out,
            do: "Check In",
            else: "Check Out" %>
        </button>
        <.link
          class="delete"
          phx-click={delete_volunteer_row(@volunteer, @id)}
          data-confirm="Are you sure?"
        >
          <.icon name="hero-trash-solid" />
        </.link>
      </div>
    </div>
    """
  end

  def toggle_volunteer_status(volunteer, id) do
    JS.push("toggle-status", value: %{id: volunteer.id})
    |> JS.transition("shake", to: "##{id}", time: 500)
  end

  def delete_volunteer_row(volunteer, id) do
    JS.push("delete", value: %{id: volunteer.id})
    |> JS.hide(
      to: "##{id}",
      transition: "ease duration-1000 scale-150"
    )
  end
end
