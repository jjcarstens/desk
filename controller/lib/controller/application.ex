defmodule Controller.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @target Mix.Project.config()[:target]

  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Controller.Supervisor]
    Supervisor.start_link(children(@target), opts)
  end

  # List all child processes to be supervised
  def children(target) do
    [
      {Controller.Reporter, []}
    ] ++ target_children(target)
  end

  defp target_children("host") do
    [
      # {Controller.Reader, [%{port: "/dev/tty.usbmodem"}]}
    ]
  end
  defp target_children("rpi" <> _) do
    [
      {Controller.Reader, []}
    ]
  end
  defp target_children(_target), do: []
end
