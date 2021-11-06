#!/usr/bin/env ruby

log = File.join(File.dirname(__FILE__), 'macs.log')
now = Time.now

mac = `/usr/local/bin/spoof-mac list --wifi`.chomp

# Exit if no MAC address found
exit if mac.empty?

# Read previous message from log
previous_message = nil
if File.readable?(log)
    begin
        last_line = File.readlines(log).last
        previous_message = last_line[/\] - (.*)\s*$/, 1] if last_line
    rescue ArgumentError
    end
end

# Log if the message changed
message = "#{mac}"
File.open(log, 'a') {|f| f.puts("[#{now}] - #{message}") } if message != previous_message
