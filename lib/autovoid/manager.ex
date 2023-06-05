defmodule Autovoid.Manager do
  alias Autovoid.ChannelSession
  use DynamicSupervisor

  @doc false
  def start_link(_opts) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl DynamicSupervisor
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  defp get_channels do
    "CHANNELS"
    |> System.fetch_env!()
    |> Jason.decode!()
  end

  def start_sessions() do
    channels = get_channels()

    Enum.map(channels, &start_channel/1)
  end

  defp start_channel(channel_id) do
    case DynamicSupervisor.start_child(__MODULE__, {ChannelSession, channel_id}) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
    end
  end
end
