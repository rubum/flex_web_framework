defmodule Flex.TemplateCache do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def get_template(path) do
    if Mix.env() == :dev do
      # In development, always read from file
      Logger.info("Reading template from file: #{path}")
      File.read!(path)
    else
      GenServer.call(__MODULE__, {:get_template, path})
    end
  end

  def invalidate(path) do
    GenServer.cast(__MODULE__, {:invalidate, path})
  end

  def handle_call({:get_template, path}, _from, state) do
    case Map.get(state, path) do
      nil ->
        Logger.info("Loading template: #{path}")
        content = File.read!(path)
        {:reply, content, Map.put(state, path, content)}
      content ->
        {:reply, content, state}
    end
  end

  def handle_cast({:invalidate, path}, state) do
    Logger.info("Invalidating template: #{path}")
    {:noreply, Map.delete(state, path)}
  end
end
