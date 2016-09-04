a#!/usr/bin/env ruby
# coding: utf-8

require 'drb'
require './icome-common'

def usage
  print <<EOF
usage:
  message message
  xcowsay message
  exec command
  get users_files (base is user's HOME) #'
  put teacher_file (base is teacher's HOME) #'
  list (list commands stored)
  delete n (delete command entry)
  reset (?)
  version
  quit
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
  when /--debug/
    $debug = true
  when /--(druby)|(uri)|(ucome)/
    druby = ARGV.shift
  when /--version/
    puts VERSION
    exit(1)
  end
end
debug "druby: #{druby}"

DRb.start_service
ucome = DRbObject.new(nil, druby)

Thread.new do
  puts "type 'quit' to quit"
  while (print "> "; cmd = STDIN.gets)
    case cmd
    when /hello/
      ucome.hello
    when /list/
      puts ucome.list
    when /^x*cowsay/
      ucome.push(cmd)
    when /^display/
      ucome.push(cmd)
    when /delete\s+(\d+)/
      ucome.delete($1.to_i)
    when /^(upload)|(get)/
      ucome.push(cmd)
    when /^(download)|(put)/
      ucome.push(cmd)
    when /^exec/
      ucome.push(cmd)
    when /^version/
      puts VERSION
    when /^reset/
      ucome.reset
    when /^quit/
      puts "quit"
      ucome.reset
      exit(0)
    else
      puts "unknown command: #{cmd}"
      usage()
    end
  end
  ucome.reset
  exit(0)
end

DRb.thread.join
