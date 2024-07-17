defmodule Flex.ResponseTest do
  use ExUnit.Case, async: true
  use Plug.Test

  defmodule TestController do
    use Flex.Response

    def test_html_response(conn) do
      html_response(conn, "test.html", %{name: "John"})
    end

    def test_json_response(conn) do
      json_response(conn, %{status: "ok"})
    end
  end

  setup do
    # Create a test connection
    conn = conn(:get, "/")
    {:ok, conn: conn}
  end

  test "html_response sets correct content type and status", %{conn: conn} do
    conn = TestController.test_html_response(conn)
    assert conn.status == 200
    assert Plug.Conn.get_resp_header(conn, "content-type") == ["text/html; charset=utf-8"]
  end

  test "json_response sets correct content type and status", %{conn: conn} do
    conn = TestController.test_json_response(conn)
    assert conn.status == 200
    assert Plug.Conn.get_resp_header(conn, "content-type") == ["application/json; charset=utf-8"]
    assert conn.resp_body == "{\"status\":\"ok\"}"
  end
end
