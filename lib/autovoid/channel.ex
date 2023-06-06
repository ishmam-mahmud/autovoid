defmodule Autovoid.Channel do
  @enforce_keys [:id, :message_ids]
  defstruct [:id, :discord_channel, message_ids: []]

  @type t :: %__MODULE__{
          id: pos_integer(),
          message_ids: list(pos_integer())
        }

  @spec new(pos_integer()) :: t()
  def new(id) when is_integer(id) do
    %__MODULE__{
      id: id,
      message_ids: []
    }
  end

  @spec add_message_ids(t(), list(pos_integer())) :: t()
  def add_message_ids(%__MODULE__{} = channel, message_ids) when is_list(message_ids) do
    Map.update(channel, :message_ids, message_ids, fn existing ->
      Enum.uniq(existing ++ message_ids)
    end)
  end

  def get_number_of_messages(%__MODULE__{} = channel) do
    length(channel.message_ids)
  end

  @spec clear_message_ids(t()) :: t()
  def clear_message_ids(%__MODULE__{} = channel) do
    Map.put(channel, :message_ids, [])
  end
end
