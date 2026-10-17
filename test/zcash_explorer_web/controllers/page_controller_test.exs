defmodule ZcashExplorerWeb.PageControllerTest do
  use ZcashExplorerWeb.ConnCase

  # The home page reads these from the cache, which the warmers fill from the
  # node. Seed them here so the page renders without a running node.
  setup do
    Cachex.put(:app_cache, "metrics", %{
      "blocks" => 1,
      "chain" => "test",
      "valuePools" => [%{"id" => "orchard", "chainValue" => 1.5}],
      "size_on_disk" => 1_048_576
    })
    Cachex.put(:app_cache, "info", %{"build" => "test"})
    Cachex.put(:app_cache, "block_cache", [])
    Cachex.put(:app_cache, "transaction_cache", [])
    on_exit(fn -> Cachex.clear(:app_cache) end)
    :ok
  end

  test "GET / renders the home page", %{conn: conn} do
    conn = get(conn, "/")
    html = html_response(conn, 200)
    assert html =~ "Orchard Pool"
    assert html =~ "1.5"
  end
end
