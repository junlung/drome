import Config

config :drome, Drome.Repo,
  ecto_repos: [Drome.Repo],
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "drome_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  migration_timestamps: [type: :timestamptz]

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Drome.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
config :drome, TMDB_API_KEY: "c840dee86e098a4dd2acc547fd731dd3"
