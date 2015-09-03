applications.select(&:repository?).map(&:repository_host).uniq.each do |repository_host|
  ssh_known_hosts_entry repository_host
end
