use Mix.Config

# Configure your database
config :albion_tools, AlbionTools.Repo,
  username: "postgres",
  password: "postgres",
  database: "albiontools_dev",
  hostname: "db",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
