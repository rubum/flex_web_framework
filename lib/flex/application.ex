defmodule Flex.Application do
  use Application
  require Logger

  def start(_type, _args) do
    port = Application.get_env(:flex_web, :port, 4000)
    url = "http://localhost:#{port}"

    cowboy_options = [port: port, dispatch: dispatch()]

    children = [
      {Plug.Cowboy, scheme: :http, plug: Flex.Router, options: cowboy_options},
      Flex.PubSub,
      {Flex.HotReloader, [dirs: [controllers_path(), templates_path()]]},
      Flex.TemplateCache
    ]

    opts = [strategy: :one_for_one, name: Flex.Supervisor]

    Logger.info("Starting Flex application on #{url}")

    case Supervisor.start_link(children, opts) do
      {:ok, pid} ->
        Logger.info("Flex application started successfully on #{url}")
        {:ok, pid}

      {:error, {:shutdown, {:failed_to_start_child, {Plug.Cowboy, _}, reason}}} ->
        Logger.error("Failed to start Flex application: #{inspect(reason)}")
        {:error, reason}

      {:error, reason} ->
        Logger.error("Failed to start Flex application: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Returns the dispatch configuration for Cowboy.
  """
  def dispatch do
    flex_router_opts = []

    [
      {:_,
       [
         {"/ws/live_reload", Flex.LiveReload, []},
         {:_, Plug.Cowboy.Handler, {Flex.Router, flex_router_opts}}
       ]}
    ]
  end

  def controllers_path do
    Application.get_env(:flex_web, :controllers_path) ||
      raise "Flex :controllers_path is not configured"
  end

  def templates_path do
    Application.get_env(:flex_web, :templates_path) ||
      raise "Flex :templates_path is not configured"
  end
end
