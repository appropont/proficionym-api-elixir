defmodule ProficionymApi.WhoisView do
  use ProficionymApi.Web, :view

  def render("show.json", %{whois: whois}) do
    render_one(whois, ProficionymApi.WhoisView, "whois.json")
  end

  def render("whois.json", %{whois: whois}) do
    %{domain: whois.domain, status: whois.status}s
  end
end
