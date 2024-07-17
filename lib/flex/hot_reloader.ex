defmodule Flex.HotReloader do
  use GenServer
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    dirs = Keyword.get(args, :dirs, [])

    case FileSystem.start_link(dirs: dirs) do
      {:ok, pid} ->
        FileSystem.subscribe(pid)
        {:ok, %{watcher_pid: pid}}

      {:error, reason} ->
        Logger.warn("FileSystem watcher could not be started: #{inspect(reason)}")
        :ignore
    end
  end

  def handle_info({:file_event, _watcher_pid, {path, _events}}, state) do
    cond do
      String.ends_with?(path, ".ex") ->
        Logger.info("Detected change in #{path}. Recompiling...")
        IEx.Helpers.recompile()
        broadcast_reload(path)

      String.ends_with?(path, ".html.eex") ->
        Logger.info("Detected change in HTML template: #{path}")
        broadcast_reload(path)

      true ->
        :ok
    end

    {:noreply, state}
  end

  def handle_info({:file_event, _watcher_pid, :stop}, state) do
    {:noreply, state}
  end

  defp broadcast_reload(path) do
    Logger.info("Broadcasting reload for #{path}")
    Flex.PubSub.broadcast("live_reload", {:reload, path})
  end
end
