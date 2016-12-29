defmodule ProficionymApi.WhoisService do
  
  # currently uses third party module. will want to create a custom one eventually
  def lookup(domain) do

    status = if status = get_cached_domain_lookup(domain) do
      status
    else
      {:ok, whois_result} = Whois.lookup(domain)
      status = "registered"
      if !whois_result.created_at do
        status = "available"
      end
      set_cached_domain_lookup(domain, status)
    end
  end

  defp get_cached_domain_lookup(domain) do
    ProficionymApi.Redix.command!(~w(GET domain:#{domain}))
  end

  defp set_cached_domain_lookup(domain, result) do
    redis_domains_expiration = 60 * 60 * 24 * 1
    command = [
      "SETEX",
      "domain:" <> domain,
      redis_domains_expiration,
      result
    ]
    ProficionymApi.Redix.command!(command)
    result
  end

end