defmodule ZcashExplorerWeb.LayoutView do
  use ZcashExplorerWeb, :view

  # LiveView 0.20 takes the live layout as a function, not a template name.
  def live(assigns), do: render("live.html", assigns)

  def bg_class(assigns) do
    case assigns[:zcash_network] do
      "testnet" ->
        "bg-purple-200 dark:bg-gray-500"

      _ ->
        "bg-gray-50 dark:bg-gray-900"
    end
  end
end
