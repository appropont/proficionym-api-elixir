defmodule ProficionymApi.WhoisController do
  use ProficionymApi.Web, :controller

  def show(conn, %{"id" => domain}) do
    whois = ProficionymApi.WhoisService.lookup(domain)
    render(conn, "show.json", whois: whois)
  end

end
