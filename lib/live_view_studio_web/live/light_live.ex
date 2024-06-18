defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, brightness: 10, temp: "3000")
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Front Porch Light</h1>
    <div id="light" phx-window-keyup="update">
      <div class="meter">
        <span style={"width: #{@brightness}%; background: #{temp_color(@temp)}"}>
          <%= @brightness %>%
        </span>
      </div>
      <div class="flex justify-between">
        <button phx-click="off">
          <img src="/images/light-off.svg" alt="off button" />
        </button>
        <button phx-click="down">
          <img src="/images/down.svg" alt="down button" />
        </button>
        <button phx-click="random">
          <img src="/images/fire.svg" alt="random button" />
        </button>
        <button phx-click="up">
          <img src="/images/up.svg" alt="up button" />
        </button>
        <button phx-click="on">
          <img src="/images/light-on.svg" alt="on button" />
        </button>
      </div>
      <form phx-change="update">
        <input
          type="range"
          min="0"
          max="100"
          name="brightness"
          value={@brightness}
          phx-debounce="100"
        />
      </form>
      <form phx-change="change-temp">
        <div class="temps">
          <%= for temp <- ["3000", "4000", "5000"] do %>
            <div>
              <input
                type="radio"
                id={temp}
                name="temp"
                value={temp}
                checked={temp == @temp}
              />
              <label for={temp}><%= temp %></label>
            </div>
          <% end %>
        </div>
      </form>
    </div>
    """
  end

  def handle_event("update", %{"key" => "ArrowUp"}, socket) do
    socket = brightness_up(socket)
    {:noreply, socket}
  end

  def handle_event("update", %{"key" => "ArrowDown"}, socket) do
    socket = brightness_down(socket)
    {:noreply, socket}
  end

  def handle_event("update", _, socket) do
    {:noreply, socket}
  end

  def handle_event("on", _unsigned_params, socket) do
    socket = assign(socket, brightness: 100)
    {:noreply, socket}
  end

  def handle_event("up", _unsigned_params, socket) do
    socket = brightness_up(socket)
    {:noreply, socket}
  end

  def handle_event("random", _unsigned_params, socket) do
    brightness = Enum.random(1..100)
    socket = assign(socket, :brightness, brightness)
    {:noreply, socket}
  end

  def handle_event("down", _unsigned_params, socket) do
    socket = brightness_down(socket)
    {:noreply, socket}
  end

  def handle_event("off", _unsigned_params, socket) do
    socket = assign(socket, brightness: 0)
    {:noreply, socket}
  end

  def handle_event("update", %{"brightness" => brightness}, socket) do
    socket = assign(socket, brightness: String.to_integer(brightness))
    {:noreply, socket}
  end

  def handle_event("change-temp", %{"temp" => temp}, socket) do
    socket = assign(socket, temp: temp)
    {:noreply, socket}
  end

  defp brightness_up(socket) do
    update(socket, :brightness, &min(&1 + 10, 100))
  end

  defp brightness_down(socket) do
    update(socket, :brightness, &max(&1 - 10, 0))
  end

  defp temp_color("3000"), do: "#F1C40D"
  defp temp_color("4000"), do: "#FEFF66"
  defp temp_color("5000"), do: "#99CCFF"
end
