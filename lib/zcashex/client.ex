defmodule Zcashex.Client do
  @moduledoc """
  Posts JSON-RPC requests to the Zcash node.

  Each call runs in the caller's process, so a slow request doesn't block
  other callers. Returns `{:ok, result}` or `{:error, message}`.
  """

  @default_timeout 120_000

  def call(method, params \\ [], timeout \\ @default_timeout) do
    config = Application.get_env(:zcash_explorer, Zcashex)
    url = "http://#{config[:zcashd_hostname]}:#{config[:zcashd_port]}"

    body =
      Poison.encode!(%{
        "jsonrpc" => "1.0",
        "id" => "zcashex",
        "method" => method,
        "params" => params
      })

    case HTTPoison.post(url, body, [{"Content-Type", "text/plain"}],
           hackney: [basic_auth: {config[:zcashd_username], config[:zcashd_password]}],
           recv_timeout: timeout
         ) do
      {:ok, %HTTPoison.Response{body: body}} ->
        decode(body)

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "node unreachable: #{inspect(reason)}"}
    end
  end

  # zcashd returns HTTP 500 with a JSON-RPC error body for failed calls,
  # so the status code isn't checked here.
  defp decode(body) do
    case Poison.decode(body) do
      {:ok, %{"error" => nil, "result" => result}} -> {:ok, result}
      {:ok, %{"error" => %{"message" => message}}} -> {:error, message}
      _ -> {:error, "unexpected response from node"}
    end
  end
end
