defmodule Flex.Router do
  use Plug.Router
  require Logger

  plug :match
  plug :dispatch

  def init(opts) do
    routes = discover_and_compile_routes()
    Keyword.put(opts, :routes, routes)
  end

  def call(conn, opts) do
    routes = Keyword.get(opts, :routes, [])
    conn = Plug.Conn.assign(conn, :flex_routes, routes)
    super(conn, opts)
  end

  defp discover_and_compile_routes do
    controllers_path = Flex.Application.controllers_path()

    if not File.dir?(controllers_path) do
      Logger.warn("Controllers path '#{controllers_path}' does not exist or is not a directory")
      []
    else
      app_name = Application.get_env(:flex_web, :otp_app) |> to_string() |> Macro.camelize()

      controllers_path
      |> File.ls!()
      |> Enum.filter(&String.ends_with?(&1, "_controller.ex"))
      |> Enum.flat_map(fn file ->
        module =
          file
          |> Path.rootname()
          |> Macro.camelize()
          |> (&"Elixir.#{app_name}.Controllers.#{&1}").()
          |> String.to_atom()

        try do
          Code.ensure_loaded!(module)

          if function_exported?(module, :__flex_routes__, 0) do
            module.__flex_routes__()
            |> Enum.map(fn {action, path, options} ->
              {module, action, path, options}
            end)
          else
            Logger.warn("Controller #{inspect(module)} does not have __flex_routes__/0 function")
            []
          end
        rescue
          e ->
            Logger.error("Failed to load controller #{inspect(module)}: #{inspect(e)}")
            []
        end
      end)
    end
  end

  match _ do
    routes = conn.assigns[:flex_routes] || []
    path = conn.request_path
    method = conn.method |> String.downcase() |> String.to_atom()

    case Enum.find(routes, fn {_, _, route_path, options} ->
      route_path == path && method in (options[:methods] || [:get])
    end) do
      {module, action, _, _} ->
        apply(module, action, [conn, conn.params])
      nil ->
        send_resp(conn, 404, "Not found")
    end
  end
end
