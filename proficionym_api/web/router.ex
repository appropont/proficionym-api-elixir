defmodule ProficionymApi.Router do
  use ProficionymApi.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ProficionymApi do
    pipe_through :api
    resources "/synonyms", SynonymsController, only: [:show]
    resources "/whois", WhoisController, only: [:show]
  end
end
