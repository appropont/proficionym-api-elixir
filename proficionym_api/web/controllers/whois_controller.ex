defmodule ProficionymApi.WhoisController do
  use ProficionymApi.Web, :controller

  def show(conn, %{"id" => domain}) do
    status = ProficionymApi.WhoisService.lookup(domain)
    render(conn, "show.json", whois: %{domain: domain, status: status})
  end

end
