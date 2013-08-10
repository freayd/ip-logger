#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'ipaddr'
require 'open-uri'

ip = previous_ip = nil
ip_regex = /\d+\.\d+\.\d+\.\d+/.to_s
log = File.join(File.dirname(__FILE__), 'ips.log')
now = Time.now.strftime('%Y-%m-%d %H:%M:%S')

# Retrieve IP:
# - http://dyn.com/support/developers/checkip-tool/
# - https://support.google.com/fiber/answer/2899098?hl=en
begin
    m = Nokogiri::HTML(open('http://checkip.dyndns.org/')).at_css('body').content.match("(#{ip_regex})\s*$")
    ip = IPAddr.new(m[1]).to_s if m
rescue ArgumentError
end

# Read previous IP from log
if File.readable?(log)
    begin
        m = File.readlines(log).last
        m = m.match("(#{ip_regex})\s*$") unless m.nil?
        previous_ip = IPAddr.new(m[1]).to_s unless m.nil?
    rescue ArgumentError
    end
end

# Log IP if changed
File.open(log, 'a') {|f| f.puts("[#{now}] - #{ip}") } unless ip == previous_ip
