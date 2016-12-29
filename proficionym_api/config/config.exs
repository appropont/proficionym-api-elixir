# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :proficionym_api, ProficionymApi.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "wozg97M/Vy8CbPxJ7yLrLaN4fJCtvrrzkDE5377tBFMyWLBiaMtPqiWScA+WFKGo",
  render_errors: [view: ProficionymApi.ErrorView, accepts: ~w(json)]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
