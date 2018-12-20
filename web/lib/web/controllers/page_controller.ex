defmodule Web.PageController do
  use Web, :controller

  def index(conn, _params) do
    render(conn, "index.html", current_height: get_current_height())
  end

  defp get_current_height do
    case :ets.lookup(:desk_heights, :jonjon) do
      [{:jonjon, height}] -> height
      _ -> 25.3
    end
  end
end
