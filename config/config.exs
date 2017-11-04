# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :ping,
  ecto_repos: [Ping.Repo]

# Configures the endpoint
config :ping, PingWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "KuSwB3wmt2Iui6f1SlK6953kZ8TdZWuAaokiYoaG36BYTeAhhsMI3k05Xhi6zqQy",
  render_errors: [view: PingWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Ping.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
