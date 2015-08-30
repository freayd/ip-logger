#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'ipaddr'
require 'json'
require 'open-uri'

sleep 1
ip_regex = /\d+\.\d+\.\d+\.\d+/
log = File.join(File.dirname(__FILE__), 'ips.log')
now = Time.now.strftime('%Y-%m-%d %H:%M:%S')

# Retrieve IP:
# - http://dyn.com/support/developers/checkip-tool/
# - https://support.google.com/fiber/answer/2899098?hl=en
# - http://forum.dyndnscommunity.com/forum/viewtopic.php?f=17&t=23
dyndns_s = Nokogiri::HTML(open('http://checkip.dyndns.org/')).at_css('body').content[ip_regex] rescue nil
dnsexit_s = Nokogiri::HTML(open('http://ip.dnsexit.com/')).at_css('body').content[ip_regex] rescue nil
duckduckgo_s = JSON.parse(Nokogiri::HTML(open('https://api.duckduckgo.com/?q=ip&format=json')).at_css('body').content)['Answer'][ip_regex] rescue nil
dyndns_ip     = IPAddr.new(dyndns_s    ).to_s if dyndns_s
dnsexit_ip    = IPAddr.new(dnsexit_s   ).to_s if dnsexit_s
duckduckgo_ip = IPAddr.new(duckduckgo_s).to_s if duckduckgo_s
ips = {
  'DynDNS'     => dyndns_ip,
  'DNSExit'    => dnsexit_ip,
  'DuckDuckGo' => duckduckgo_ip
}

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
  if ips.values.first.nil? || ips.values.uniq.size != 1
    ips.map { |service, ip| "#{service}:#{ip}" }.join(' ')
  else
    ips.values.first
  end
File.open(log, 'a') {|f| f.puts("[#{now}] - #{message}") } if message != previous_message
