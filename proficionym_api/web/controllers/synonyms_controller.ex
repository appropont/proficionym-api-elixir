defmodule ProficionymApi.SynonymsController do
  use ProficionymApi.Web, :controller

  def show(conn, %{"id" => word}) do
    synonyms = ProficionymApi.SynonymsService.getSynonyms(word)
    render(conn, "show.json", synonyms: synonyms)
  end

end
