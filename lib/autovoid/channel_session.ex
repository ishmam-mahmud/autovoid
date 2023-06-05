defmodule Autovoid.ChannelSession do
  use GenServer

  alias Autovoid.Channel

  @interval 1000

  def start_link(channel_id) when is_integer(channel_id) do
    GenServer.start_link(__MODULE__, channel_id, name: global_name(channel_id))
  end

  @impl GenServer
  def init(channel_id) do
    Process.send_after(self(), :get_messages, @interval)
    {:ok, Channel.new(channel_id)}
  end

  @impl GenServer
  def handle_info(:get_messages, %Channel{} = channel) do
    IO.inspect(channel)
    messages = Nostrum.Api.get_channel_messages!(channel.id, 2) |> IO.inspect()
    message_ids = Enum.map(messages, fn %Nostrum.Struct.Message{} = message -> message.id end)
    updated_channel = Channel.add_message_ids(channel, message_ids)
    Process.send_after(self(), :delete_messages, @interval)
    {:noreply, updated_channel}
  end

  @impl GenServer
  def handle_info(:delete_messages, %Channel{} = channel) do
    {:ok} = Nostrum.Api.bulk_delete_messages!(channel.id, channel.message_ids)

    updated_channel = Channel.clear_message_ids(channel)

    Process.send_after(self(), :get_messages, @interval)

    {:noreply, updated_channel}
  end

  def whereis(channel_id) do
    case :global.whereis_name({__MODULE__, channel_id}) do
      :undefined -> nil
      pid -> {:ok, pid}
    end
  end

  def global_name(channel_id) do
    {:global, {__MODULE__, channel_id}}
  end
end
