# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :awesome_list,
  ecto_repos: [AwesomeList.Repo]

# Configures the endpoint
config :awesome_list, AwesomeListWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "fH3GhIZEuug6DVUFHtWfJ6/qEaU0fOhy1hjmGdmIsp7NZlllQS1CQ1fpPspK6zqS",
  render_errors: [view: AwesomeListWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: AwesomeList.PubSub,
  live_view: [signing_salt: "qpA4T6Hl"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# новую пару можно получить на https://github.com/settings/applications/1356944 (для юзера awesome-lists-user)
config :awesome_list, AwesomeList.Github.Client,
  client_id: "b952f1fc35eff9cb8e37",
  client_secret: "48454e193e12c3c74efc20f1c63ef2241d2463d9"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
