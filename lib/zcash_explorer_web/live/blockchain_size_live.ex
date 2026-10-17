defmodule ZcashExplorerWeb.BlockChainSizeLive do
  use ZcashExplorerWeb, :live_view
  import Phoenix.Component
  @impl true
  def render(assigns) do
    ~H"""
    <p class="text-2xl font-semibold text-gray-900 dark:dark:bg-slate-800 dark:text-slate-100">
    <%= if @blockchain_size, do: Sizeable.filesize(@blockchain_size), else: "loading..." %>
    </p>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 15000)

    {:ok, info} = Cachex.get(:app_cache, "metrics")
    {:ok, assign(socket, :blockchain_size, info && info["size_on_disk"])}
  end

  @impl true
  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 15000)
    {:ok, info} = Cachex.get(:app_cache, "metrics")
    {:noreply, assign(socket, :blockchain_size, info && info["size_on_disk"])}
  end
end
