defmodule ProficionymApi.SynonymsView do
  use ProficionymApi.Web, :view

  def render("show.json", %{synonyms: synonyms}) do
    render_one(synonyms, ProficionymApi.SynonymsView, "synonyms.json")
  end

  def render("synonyms.json", %{synonyms: synonyms}) do
    %{synonyms: synonyms}
  end
end
