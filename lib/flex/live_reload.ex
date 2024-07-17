defmodule Flex.LiveReload do
  @behaviour :cowboy_websocket
  require Logger

  def init(req, state) do
    {:cowboy_websocket, req, state}
  end

  def websocket_init(state) do
    Logger.info("WebSocket connection initialized")
    Flex.PubSub.subscribe("live_reload")
    {:ok, state}
  end

  def websocket_handle({:text, "ping"}, state) do
    {:reply, {:text, "pong"}, state}
  end

  def websocket_info({:broadcast, "live_reload", {:reload, path}}, state) do
    Logger.info("Received reload message for path: #{path}")
    {:reply, {:text, "reload"}, state}
  end

  def terminate(_reason, _req, _state) do
    :ok
  end
end
