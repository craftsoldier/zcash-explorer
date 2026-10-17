use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :zcash_explorer, ZcashExplorer.Repo,
  username: "postgres",
  password: "postgres",
  database: "zcash_explorer_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :zcash_explorer, ZcashExplorerWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Node settings the app reads at boot. Tests run without a node, so the
# warmers log "node unreachable" and carry on.
config :zcash_explorer, Zcashex,
  zcashd_hostname: "localhost",
  zcashd_port: "8232",
  zcashd_username: "test",
  zcashd_password: "test",
  zcash_network: "testnet"
