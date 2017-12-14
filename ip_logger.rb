#!/usr/bin/env ruby
require 'ipaddr'
require 'json'
require 'open-uri'

sleep 1
ip_regex = /\d+\.\d+\.\d+\.\d+/
log = File.join(File.dirname(__FILE__), 'ips.log')
now = Time.now

# Retrieve IP:
# - http://dyn.com/support/developers/checkip-tool/
# - https://support.google.com/fiber/answer/2899098?hl=en
# - http://forum.dyndnscommunity.com/forum/viewtopic.php?f=17&t=23
dyndns_s = open('http://checkip.dyndns.org/').read[ip_regex] rescue nil
dnsexit_s = open('http://ip.dnsexit.com/').read[ip_regex] rescue nil
duckduckgo_s = JSON.parse(open('https://api.duckduckgo.com/?q=ip&format=json').read)['Answer'][ip_regex] rescue nil
whatismyip_s = open('https://www.whatismyip.com/ip-address-lookup/', 'User-Agent' => 'Agent').read[/(?<=name="ip" class="form-control" value=")[^"]+(?=")/] rescue nil
whatismyipaddress_s = open("https://whatismyipaddress.com/").read[/(?<=<a href="\/\/whatismyipaddress.com\/ip\/)[^"]+(?=">)/] rescue nil
dyndns_ip            = IPAddr.new(dyndns_s           ) if dyndns_s
dnsexit_ip           = IPAddr.new(dnsexit_s          ) if dnsexit_s
duckduckgo_ip        = IPAddr.new(duckduckgo_s       ) if duckduckgo_s
whatismyip_ip        = IPAddr.new(whatismyip_s       ) if whatismyip_s
whatismyipaddress_ip = IPAddr.new(whatismyipaddress_s) if whatismyipaddress_s
ips = {
  'DynDNS'            => dyndns_ip,
  'DNSExit'           => dnsexit_ip,
  'DuckDuckGo'        => duckduckgo_ip,
  'WhatIsMyIP'        => whatismyip_ip,
  'WhatIsMyIPAddress' => whatismyipaddress_ip,
}
ips_v4 = ips.select { |service, ip| ip&.ipv4? }
ips_v6 = ips.select { |service, ip| ip&.ipv6? }

# Exit if no IP found
exit if ips.values.compact.empty?

# Read previous message from log
previous_message = nil
if File.readable?(log)
    begin
        last_line = File.readlines(log).last
        previous_message = last_line[/\] - (.*)\s*$/, 1] if last_line
    rescue ArgumentError
    end
end

# Log unless the message haven't changed
message =
  if ips_v4.values.compact.uniq.size > 1 || ips_v6.values.compact.uniq.size > 1
    ips.map { |service, ip| "#{service}:#{ip}" }.join(' ')
  else
    [ ips_v4.values.compact.first, ips_v6.values.compact.first ].compact.join(' / ')
  end
File.open(log, 'a') {|f| f.puts("[#{now}] - #{message}") } if message != previous_message
