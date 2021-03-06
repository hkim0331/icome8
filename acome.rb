#!/usr/bin/env ruby
# coding: utf-8

require 'drb'
require_relative 'icome-common'

def usage
  print <<EOF
acome #{VERSION}
# usage:

$ acome [--debug] [--ucome druby://ucome_ip:port]

# online methods

  [display|dialog|xcowsay] message
  upload file
  download file (not yet)
  exec command
  reset n (BUG: infinite loop)

  list
  enable n
  disable n
  clear

  [druby|ucome]
  mongo

to exit, type ^C.
EOF
end

#
# main starts here
#

debug = (ENV['DEBUG'] || false)
ucome = (ENV['UCOME'] || UCOME)

while (arg = ARGV.shift)
  case arg
  when /--debug/
    debug = true
  when /--(ucome)|(druby)/
    ucome = ARGV.shift
  else
    usage()
    exit(1)
  end
end

DRb.start_service
@ucome = DRbObject.new(nil, ucome)

Thread.new do
  puts "ucome: #{ucome}"
  puts "type ^C to quit"
  while (print "> "; cmd = STDIN.gets.strip)
    case cmd

    # commands to icome
    when /^(display)|(dialog)|(xcowsay)|(upload)|(download)|(exec)|(reset)/
      @ucome.push(cmd)

    # commands from acome
    when /list/
      puts @ucome.list
    when /^enable\s+(\d+)/
      @ucome.enable($1.to_i)
    when /^disable\s+(\d+)/
      @ucome.disable($1.to_i)
    when /^clear/
      @ucome.clear

    when /^(ucome)|(druby)/
      puts ucome

    when /^mongo/
      puts @ucome.mongo

    when /^version/
      puts VERSION

    when /^quit/
      puts "quit"
      quit = true

    else
      puts "unknown command: #{cmd}"
      usage()
    end
  end

end

DRb.thread.join

