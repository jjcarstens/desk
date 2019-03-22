defmodule Web.RandomsCommander do
  use Drab.Commander
  require Logger
  alias Phoenix.Socket.Broadcast

  onconnect :connected

  # Drab Callbacks
  def connected(socket) do
    Web.Endpoint.subscribe("randomizer")
    watcher_loop(socket)
  end

  defp watcher_loop(socket) do
    receive do
      %Broadcast{event: "truck_selection", payload: %{"name" => name}} ->
        poke(socket, selected: name)
      wat ->
        Logger.error("[#{__MODULE__}] I'm not sure what this is? - #{inspect(wat)}")
    end
    watcher_loop(socket)
  end
end
