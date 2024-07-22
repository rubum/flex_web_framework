defmodule Flex.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  defmodule TestController do
    use Flex.Router

    defroute :index, "/users" do
      send_resp(conn, 200, "Users Index")
    end

    defroute :show, "/users/:id" do
      id = conn.params["id"]
      send_resp(conn, 200, "User #{id}")
    end

    defroute :create, "/users", methods: [:post] do
      send_resp(conn, 201, "User Created")
    end

    defroute :update, "/users/:id", methods: [:put, :patch] do
      id = conn.params["id"]
      send_resp(conn, 200, "User #{id} Updated")
    end

    defroute :complex, "/users/:id/posts/:post_id" do
      id = conn.params["id"]
      post_id = conn.params["post_id"]
      name = conn.params["name"]
      send_resp(conn, 200, "User #{id}, Post #{post_id}, Name: #{name}")
    end
  end

  test "GET /users" do
    conn = conn(:get, "/users")
    conn = TestController.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Users Index"
    assert conn.private.flex_controller == TestController
    assert conn.private.flex_action == :index
  end

  test "GET /users/:id?q=name" do
    conn = conn(:get, "/users/123?q=foo")
    conn = TestController.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "User 123"
    assert conn.private.flex_controller == TestController
    assert conn.private.flex_action == :show
  end

  test "404 for non-existent route" do
    conn = conn(:get, "/non_existent")
    conn = TestController.call(conn, [])

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "Not found"
  end
end
