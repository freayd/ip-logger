#!/usr/bin/env ruby
require 'ipaddr'

def ip_list(type: String)
  fail ArgumentError unless [String, IPAddr].include?(type)

  ips = []
  File.open(File.join(File.dirname(__FILE__), 'ips.log')).each do |line|
    ip = line[/ - ([\da-f\.:]+)$/, 1]
    next if ip.nil?
    ip = IPAddr.new(ip) if type == IPAddr
    ips << ip unless ips.include?(ip)
  end
  ips
end
