defmodule Flex.PubSub do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def subscribe(topic) do
    GenServer.call(__MODULE__, {:subscribe, topic, self()})
  end

  def broadcast(topic, message) do
    GenServer.cast(__MODULE__, {:broadcast, topic, message})
  end

  def handle_call({:subscribe, topic, pid}, _from, state) do
    new_state = Map.update(state, topic, [pid], fn pids -> [pid | pids] end)
    {:reply, :ok, new_state}
  end

  def handle_cast({:broadcast, topic, message}, state) do
    for pid <- Map.get(state, topic, []) do
      send(pid, {:broadcast, topic, message})
    end

    {:noreply, state}
  end
end
