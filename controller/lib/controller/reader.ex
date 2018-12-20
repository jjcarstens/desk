defmodule Controller.Reader do
  use GenServer
  alias Circuits.UART
  alias Controller.Reporter

  def start_link(state) when is_list(state), do: start_link(Map.new(state))
  def start_link(state) when is_map(state) do
    state = state
            |> Map.put_new(:port, "ttyAMA0")
            |> Map.put(:current_height, "25.3") # Arbitrary default height (my current minimum allowed height)
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    send self(), :init
    {:ok, state}
  end

  def handle_info(:init, %{port: port} = state) do
    {:ok, uart} = UART.start_link()
    :ok = UART.open(uart, port, framing: UART.Framing.FourByte, rx_framing_timeout: 10)
    {:noreply, Map.put(state, :uart, uart)} # just for reference
  end

  def handle_info({:circuits_uart, name, <<1, 1, buff, height>>}, %{port: port} = state) when name == port do
    [tens, ones, tenths] = case buff do
                             1 -> 256 + height
                             0 -> height
                           end
                           |> Integer.digits()

    new_height = "#{tens}#{ones}.#{tenths}" |> String.to_float()

    if new_height != state.current_height do
      send Reporter, {:height_update, new_height}
    end

    {:noreply, %{state | current_height: new_height}}
  end

  # ignore messages we don't care about
  def handle_info({:circuits_uart, _, _}, state), do: {:noreply, state}
end
