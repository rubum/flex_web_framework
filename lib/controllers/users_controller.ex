defmodule User.Controller do
  use Flex.Routes
  use Flex.Response
  require Logger

  defroute :home, "/", methods: [:get, :post] do
    Logger.info("Handling home route")
    Logger.info("Params: #{inspect(params)}")
    assigns = %{name: "Doe"}
    html_response(conn, "templates/home.html", assigns)
  end

  defroute :not_found, "/*path", methods: [:get, :post, :put, :delete, :patch] do
    Logger.info("Handling not_found route")
    Logger.info("Params: #{inspect(params)}")
    Plug.Conn.send_resp(conn, 404, "Not Found")
  end
end
