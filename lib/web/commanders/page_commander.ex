defmodule Web.PageCommander do
  use Drab.Commander
  require Logger
  alias Phoenix.Socket.Broadcast

  onconnect :connected

  # Drab Callbacks
  def connected(socket) do
    Web.Endpoint.subscribe("desk_controller:jonjon")
    current_height_update_loop(socket)
  end

  defp current_height_update_loop(socket) do
    receive do
      %Broadcast{event: "height_update", payload: %{"current_height" => new_height}} ->
        :ets.insert(:desk_heights, {:jonjon, new_height})
        poke(socket, current_height: new_height)
      wat ->
        Logger.error("[#{__MODULE__}] I'm not sure what this is? - #{inspect(wat)}")
    end
    current_height_update_loop(socket)
  end
end
