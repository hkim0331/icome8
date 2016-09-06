#!/usr/bin/env ruby
# coding: utf-8

require 'drb'
require './icome-common'

def usage
  print <<EOF
usage:
  display message
  xcowsay message
  upload file
  download file
  exec command
  reset n

  list
  enable n
  disable n
  clear

  druby
  VERSION
EOF
end

#
# main starts here
#

$debug = (ENV['DEBUG'] || false)
druby = (ENV['UCOME'] || 'druby://127.0.0.1:9007')
while (arg = ARGV.shift)
  case arg
  when /--help/
    usage()
  when /--(druby)|(uri)|(ucome)/
    druby = ARGV.shift
  when /--version/
    puts VERSION
  else
    usage()
  end
end

DRb.start_service
ucome = DRbObject.new(nil, druby)

Thread.new do
  puts "type 'quit' to quit"
  quit = false
  while (print "> "; cmd = STDIN.gets.strip)
    case cmd
    # commands to icome
    when /^(display)|(xcowsay)|(upload)|(download)|(exec)|(reset)/
      ucome.push(cmd)

    # commands from acome
    when /list/
      puts ucome.list
    when /^enable\s+(\d+)/
      ucome.enable($1.to_i)
    when /^disable\s+(\d+)/
      ucome.disable($1.to_i)
    when /^clear/
      ucome.clear

    when /druby/
      puts druby
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

