defmodule Flex.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Flex.Router

  test "routes to the correct controller action" do
    defmodule TestController do
      use Flex.Routes

      defroute :home, "/", methods: [:get] do
        send_resp(conn, 200, "Home")
      end
    end

    opts = Router.init(controller: TestController)
    conn = conn(:get, "/")
    conn = Router.call(conn, opts)

    assert conn.status == 200
    assert conn.resp_body == "Home"
  end

  test "returns 404 for unknown routes" do
    defmodule EmptyController do
      use Flex.Routes
    end

    opts = Router.init(controller: EmptyController)
    conn = conn(:get, "/unknown")
    conn = Router.call(conn, opts)

    assert conn.status == 404
  end
end
