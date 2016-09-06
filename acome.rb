#!/usr/bin/env ruby
# coding: utf-8

require 'drb'
require './icome-common'

def usage
  print <<EOF
usage:
---not yet prepared---
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
    puts "cmd: #{cmd}"

    case cmd
    when /enable\s+(\d+)/
      ucome.enable($1.to_i)
    when /disable\s+(\d+)/
      ucome.disable($1.to_i)
    when /delete\s+(\d+)/
      ucome.delete($1.to_i)
    when /^reset/
      ucome.reset

    when /^(display)|(message)/
      ucome.push(cmd)
    when /^x*cowsay/
      ucome.push(cmd)
    when /list/
      puts ucome.list
    when /^(upload)|(get)/
      ucome.push(cmd)
    when /^(download)|(put)/
      ucome.push(cmd)
    when /^exec/
      ucome.push(cmd)

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

