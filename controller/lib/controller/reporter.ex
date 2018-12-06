defmodule Controller.Reporter do
  use WebSockex
  require Logger

  def start_link(state) do
    url = Application.get_env(:controller, :websocket_url)
    id = Application.get_env(:controller, :id)
    WebSockex.start_link("#{url}?controller_id=#{id}", __MODULE__, state, name: __MODULE__, async: true, handle_initial_conn_failure: true)
  end

  @impl true
  def handle_connect(_conn, state) do
    send self(), :join
    {:ok, state}
  end

  @impl true
  def handle_disconnect(_conn_map, state) do
    Logger.error("Websocket Disconnect: Attempting reconnect")
    {:reconnect, state}
  end

  @impl true
  def handle_frame({:text, msg}, state) do
    Logger.info("WEBSOCKET RECEIVE: #{msg}")
    {:ok, state}
  end

  @impl true
  def handle_info({:height_update, new_height}, state) do
    msg = %{
      payload: %{current_height: new_height},
      event: "height_update",
      topic: "desk_controller:jonjon",
      ref: "sdfarewr"
    } |> Jason.encode!()

    {:reply, {:text, msg}, state}
  end

  @impl true
  def handle_info(:join, state) do
    join_payload = %{
      payload: %{},
      event: "phx_join",
      topic: "desk_controller:jonjon",
      ref: "lbkajldkfjawr",
      join_ref: "oijwpejpasfsf"
    } |> Jason.encode!()

    {:reply, {:text, join_payload}, state}
  end

  @impl true
  def handle_cast({:send, frame}, state) do
    {:reply, frame, state}
  end
end
