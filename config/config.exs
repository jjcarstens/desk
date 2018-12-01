use Mix.Config

# General application configuration
config :web,
  generators: [context_app: false]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures the endpoint
config :web, Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "q2w8m0ppiEz8+5DUjnchjLMfTHo+7mSC7Q69sJ3P9M1AnzfwfM0bTIaulLA0Z5JU",
  render_errors: [view: Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Web.PubSub, adapter: Phoenix.PubSub.PG2]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
