defmodule Autovoid.ChannelSession do
  use GenServer

  alias Autovoid.Channel

  @interval 60_000
  @get_messages_limit 100
  @min_messages_delete 2

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
    {:ok, messages} = Autovoid.Discord.get_channel_messages(channel.id)
    message_ids = Enum.map(messages, fn message -> message.id end)
    updated_channel = Channel.add_message_ids(channel, message_ids)
    Process.send_after(self(), :delete_messages, @interval)
    {:noreply, updated_channel}
  end

  @impl GenServer
  def handle_info(:delete_messages, %Channel{} = channel) do
    case Channel.get_number_of_messages(channel) do
      1 ->
        [message_id] = channel.message_ids
        Autovoid.Discord.delete_message(channel.id, message_id)

      num_messages when num_messages >= @min_messages_delete ->
        Autovoid.Discord.bulk_delete_messages(channel.id, channel.message_ids)

      _other ->
        {:ok}
    end

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
