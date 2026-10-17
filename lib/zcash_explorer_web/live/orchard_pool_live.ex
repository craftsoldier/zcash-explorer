defmodule ZcashExplorerWeb.OrchardPoolLive do
  use ZcashExplorerWeb, :live_view
  import Phoenix.Component
  @impl true
  def render(assigns) do
    ~H"""
    <p class="text-2xl font-semibold text-gray-900 dark:dark:bg-slate-800 dark:text-slate-100">
    <%= if @blockchain_info do %>
    <%= orchard_value(@blockchain_info["valuePools"]) %> <%= currency(@blockchain_info) %>
    <% else %>
    loading...
    <% end %>
    </p>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 15000)

    {:ok, assign(socket, :blockchain_info, load_blockchain_info())}
  end

  @impl true
  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 15000)
    {:noreply, assign(socket, :blockchain_info, load_blockchain_info())}
  end

  # nil until both the metrics and info keys have been warmed
  defp load_blockchain_info do
    {:ok, info} = Cachex.get(:app_cache, "metrics")
    {:ok, node_info} = Cachex.get(:app_cache, "info")
    if info && node_info, do: Map.put(info, "build", node_info["build"])
  end

  defp orchard_value(value_pools) do
    value_pools |> get_value_pools |> Map.get("orchard")
  end

  defp get_value_pools(value_pools) do
    Enum.map(value_pools, fn %{"id" => name, "chainValue" => value} -> {name, value} end)
    |> Map.new()
  end

  defp currency(blockchain_info) do
    if(blockchain_info["chain"] == "main", do: "ZEC", else: "TAZ")
  end
end
