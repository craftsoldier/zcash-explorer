defmodule Zcashex do
  @moduledoc """
  Zcash node RPC calls used by the explorer.

  Each function returns `{:ok, result}` or `{:error, message}`. The
  method list covers only the calls the explorer makes.
  """

  alias Zcashex.Client

  def getinfo, do: Client.call("getinfo")
  def getblockchaininfo, do: Client.call("getblockchaininfo")
  def getmempoolinfo, do: Client.call("getmempoolinfo")
  def getpeerinfo, do: Client.call("getpeerinfo")
  def getnetworksolps, do: Client.call("getnetworksolps")

  def getrawmempool(verbose), do: Client.call("getrawmempool", [verbose])

  def getblock(hash, verbosity) when is_binary(hash) and verbosity in 0..2 do
    Client.call("getblock", [hash, verbosity])
  end

  def getblockheader(hash), do: Client.call("getblockheader", [hash])

  def getblockhashes(high, low, no_orphans \\ true, logical_times \\ true)
      when is_integer(high) and is_integer(low) do
    Client.call("getblockhashes", [
      high,
      low,
      %{"noOrphans" => no_orphans, "logicalTimes" => logical_times}
    ])
  end

  def getrawtransaction(txid, verbosity \\ 1) when verbosity in 0..2 do
    Client.call("getrawtransaction", [txid, verbosity])
  end

  def sendrawtransaction(hex), do: Client.call("sendrawtransaction", [hex])

  def z_validatepaymentdisclosure(hex), do: Client.call("z_validatepaymentdisclosure", [hex])

  def getaddressbalance(taddr) when is_binary(taddr) do
    Client.call("getaddressbalance", [%{"addresses" => [taddr]}])
  end

  def getaddressdeltas(taddr, start_block \\ nil, end_block \\ nil, chaininfo \\ true) do
    Client.call("getaddressdeltas", [
      %{
        "addresses" => [taddr],
        "start" => start_block,
        "end" => end_block,
        "chainInfo" => chaininfo
      }
    ])
  end

  def validateaddress(address), do: Client.call("validateaddress", [address])
  def z_validateaddress(address), do: Client.call("z_validateaddress", [address])

  def z_listunifiedreceivers(unified_address) do
    Client.call("z_listunifiedreceivers", [unified_address])
  end
end
