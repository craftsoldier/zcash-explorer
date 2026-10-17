defmodule ZcashExplorerWeb.BlockController do
  use ZcashExplorerWeb, :controller

  def get_block(conn, %{"hash" => hash}) do
    {:ok, basic_block_data} = Zcashex.getblock(hash, 1)

    case length(basic_block_data["tx"]) do
      0 ->
        {:error, :no_tx}

      n when n <= 250 ->
        {:ok, block_data} = Zcashex.getblock(hash, 2)
        block_data = Zcashex.Block.from_map(block_data)
        height = block_data.height

        render(conn, "index.html",
          block_data: block_data,
          block_subsidy: nil,
          page_title: "Zcash block #{height}"
        )

      n when n > 250 ->
        render(conn, "basic_block.html",
          block_data: basic_block_data,
          page_title: "Zcash block #{hash}"
        )
    end
  end

  def index(conn, %{"date" => date}) do
    max_concurrency = System.schedulers_online() * 2
    parsed_date = Date.from_iso8601!(date)
    diff = Date.diff(parsed_date, Date.utc_today())

    if diff > 0 do
      conn
      |> put_status(:not_found)
      |> put_view(ZcashExplorerWeb.ErrorView)
      |> render(:invalid_input)
    end

    previous = parsed_date |> Date.add(-1) |> Date.to_iso8601()
    next = parsed_date |> Date.add(1) |> Date.to_iso8601()
    first_block_date = "2016-10-28"
    disable_previous = if first_block_date == date, do: true, else: false

    disable_next = if Date.utc_today() |> Date.to_iso8601() == date, do: true, else: false

    high = unix_end_of_day(parsed_date)
    low = unix_start_of_day(parsed_date)

    case Zcashex.getblockhashes(high, low, true, false) do
      {:ok, blocks} ->
        blocks_data =
          blocks
          |> Task.async_stream(fn block -> Zcashex.getblockheader(block) end,
            max_concurrency: max_concurrency,
            ordered: false
          )
          |> Enum.to_list()
          |> Enum.map(fn {task, {:ok, res}} -> res end)
          |> Enum.reverse()

        render(
          conn,
          "blocks.html",
          blocks_data: blocks_data,
          date: date,
          disable_next: disable_next,
          disable_previous: disable_previous,
          next: next,
          previous: previous,
          page_title: "Zcash blocks mined on #{date}"
        )
    end
  end

  def index(conn, _params) do
    max_concurrency = System.schedulers_online() * 2
    today = Date.utc_today()
    high = DateTime.utc_now() |> DateTime.to_unix()
    low = unix_start_of_day(today)
    disable_next = true
    disable_previous = false
    previous = Date.add(today, -1)

    case Zcashex.getblockhashes(high, low, true, false) do
      {:ok, blocks} ->
        blocks_data =
          blocks
          |> Task.async_stream(fn block -> Zcashex.getblockheader(block) end,
            max_concurrency: max_concurrency,
            ordered: false
          )
          |> Enum.to_list()
          |> Enum.map(fn {task, {:ok, res}} -> res end)
          |> Enum.reverse()

        render(conn, "blocks.html",
          blocks_data: blocks_data,
          date: today,
          disable_next: disable_next,
          disable_previous: disable_previous,
          previous: previous,
          page_title: "Zcash latest blocks"
        )
    end
  end

  defp unix_start_of_day(date) do
    date |> DateTime.new!(~T[00:00:00], "Etc/UTC") |> DateTime.to_unix()
  end

  defp unix_end_of_day(date) do
    date |> DateTime.new!(~T[23:59:59], "Etc/UTC") |> DateTime.to_unix()
  end
end
