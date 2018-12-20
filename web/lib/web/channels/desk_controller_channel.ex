defmodule Web.DeskControllerChannel do
  use Web, :channel

  def join("desk_controller:" <> name, _payload, socket) do
    {:ok, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (desk_controller:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_in("height_update", payload, socket) do
    case validate_height(payload) do
      :ok ->
        broadcast_from! socket, "height_update", payload
        {:noreply, socket}
      error ->
        {:reply, error, socket}
    end
  end

  defp validate_height(%{"current_height" => height}) when is_float(height), do: :ok
  defp validate_height(%{"current_height" => _height}) do
    {:error, %{message: "current_height must be a float"}}
  end
  defp validate_height(_payload) do
    {:error, %{message: "payload must include current_height key with a float value"}}
  end
end
