defmodule Web.RandomsController do
  use Web, :controller

  def index(conn, _params) do
    conn
    |> assign(:selected, "??")
    |> render(:index)
  end
end
