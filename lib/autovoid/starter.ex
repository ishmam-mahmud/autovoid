defmodule Autovoid.Starter do
  use GenServer

  alias Autovoid.Manager

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(_opts) do
    {:ok, nil, {:continue, :startup}}
  end

  def handle_continue(:startup, state) do
    Manager.start_sessions()

    {:noreply, state}
  end
end
