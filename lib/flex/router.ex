defmodule Flex.Router do
  import Plug.Router

  def init(opts), do: opts

  defmacro __using__(_opts) do
    quote do
      use Plug.Router

      import Flex.Router

      plug(Plug.Parsers,
        parsers: [:urlencoded, :multipart, :json],
        pass: ["*/*"],
        json_decoder: Jason
      )

      plug(:match)
      plug(:dispatch)

      @before_compile Flex.Router
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      match _ do
        send_resp(var!(conn), 404, "Not found")
      end
    end
  end

  defmacro defroute(action, path, options \\ [], do: block) do
    quote do
      def do_route(var!(conn) = conn, unquote(path), unquote(action)) do
        unquote(block)
      end

      defp match_route(unquote(path), conn) do
        var!(conn) = merge_params(conn)

        var!(conn) = %{
          var!(conn)
          | private:
              Map.merge(var!(conn).private, %{
                flex_controller: __MODULE__,
                flex_action: unquote(action)
              })
        }

        do_route(var!(conn), unquote(path), unquote(action))
      end

      methods = unquote(options)[:methods] || [:get]

      Enum.each(methods, fn method ->
        match(unquote(path), via: method, do: match_route(unquote(path), var!(conn)))
      end)
    end
  end

  def merge_params(conn) do
    merged_params =
      Map.merge(conn.params, conn.path_params)
      |> Map.merge(conn.query_params || %{})
      |> Map.merge(conn.body_params || %{})

    %{conn | params: merged_params}
  end
end
