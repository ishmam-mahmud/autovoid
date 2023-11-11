defmodule Autovoid.Discord do
  def get_channel_messages(channel_id) when is_integer(channel_id) do
    %Req.Response{status: 200, body: messages} =
      base_request()
      |> Req.get!(
        url: "/channels/:channel_id/messages",
        path_params: [channel_id: channel_id],
        params: [limit: 100]
      )

    {:ok,
     messages
     |> Enum.map(fn message ->
       {id, _rest} = Integer.parse(message["id"])
       %{id: id}
     end)}
  end

  def delete_message(channel_id, message_id)
      when is_integer(channel_id) and is_integer(message_id) do
    base_request()
    |> Req.delete!(
      url: "/channels/:channel_id/messages/:message_id",
      path_params: [channel_id: channel_id, message_id: message_id],
      headers: [{"X-Audit-Log-Reason", "Demontoast: venting void autodelete"}]
    )
  end

  def bulk_delete_messages(channel_id, message_ids)
      when is_integer(channel_id) and is_list(message_ids) do
    base_request()
    |> Req.post!(
      url: "/channels/:channel_id/messages/bulk-delete",
      path_params: [channel_id: channel_id],
      json: %{messages: message_ids},
      headers: [{"X-Audit-Log-Reason", "Demontoast: venting void autodelete"}]
    )
  end

  defp base_request do
    Req.new(
      base_url: "https://discord.com/api/v10",
      auth: "Bot #{System.fetch_env!("DISCORD_TOKEN")}"
    )
  end
end
