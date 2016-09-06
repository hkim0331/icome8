#!/usr/bin/env ruby
# coding: utf-8
#
# will work on vm2016, ruby 2.3.1.

require 'mongo'
require 'drb'
require 'socket'
require 'logger'
require './icome-common'

def usage()
  print <<EOF
ucome #{VERSION}
usage:
ucome [--mongodb mongodb://server:port/db]
      [--druby druby://ip_address:port]
EOF
  exit(1)
end

class Ucome
  attr_reader :reset_count

  def initialize(mongo = 'mongodb://localhost/ucome')
    if $debug || !!ENV['DEBUG']
      @upload = "./upload"
      logger       = Logger.new(STDERR)
      logger.level = Logger::DEBUG
    else
      @upload = "/srv/icome8/upload"
      logger       = Logger.new("/srv/icome8/log/ucome.log", 5, 10*1024)
      logger.level = Logger::INFO
    end
    @cl = Mongo::Client.new(mongo, logger: logger)[collection()]
    @commands = []
    @cur = 0
    @next = -1
  end

  def create(sid, uhour)
    @cl.insert_one({sid: sid, uhour: uhour, icome: [], ip: []})
  end

  def update(sid, uhour, date, ip)
    @cl.update_one({sid: sid, uhour: uhour},
                   {"$addToSet" => {icome: date, ip: ip}})
  end

  def find_icome(sid, uhour)
    ret = @cl.find({sid: sid, uhour: uhour})
    # CHECK: should return false?
    if ret.first.nil?
      []
    else
      ret.first[:icome]
    end
  end

  # 個人課題の提出状況。
  # 個人課題は ucome の動くサーバにアップロードするので、
  # icome のローカル PC では解決できない。
  def personal(sid)
    dir = File.join(@upload, sid)
    if File.directory?(dir)
      Dir.entries(dir).delete_if{|x| x=~/^\./}
    else
      []
    end
  end

  # %F_#{save_as_name} は並び順のため。
  def upload(from_sid, save_as_name, contents)
    dir = File.join(UPLOAD, from_sid)
    Dir.mkdir(dir) unless File.directory?(dir)
    to = File.join(dir, Time.now.strftime("%F_#{save_as_name}"))
    File.open(to, "w") do |f|
      f.puts contents
    end
  end

  # commands interface
  # acome の仕事。
  def push(cmd)
    @commands.push({status: :enable, command: cmd})
  end

  def list
    ret = []
    @commands.each_with_index do |cmd, index|
      ret.push "#{index}: #{cmd}"
    end
    ret
  end

  # スタックトップを消すとは限らない。
  def delete(n)
    @commands.delete_at(n)
  end

  # delete の代わりに enable/disable
  def enable(n)
    @commands[n][:status] = :enable
  end

  def disable(n)
    @commands[n][:status] = :disable
  end

  def clear
    @commands=[]
  end

  # icome
  # if not found, return nil.
  def fetch(n)
    @commands.delete_if{|com| com[:status]==:disable}[n]
  end

end

#
# main starts here.
#
$debug = false
druby = (ENV['UCOME'] || 'druby://128.0.0.1:9007')
mongo = (ENV['UCOME_MONGO'] || 'mongodb://localhost/ucome')
while (arg = ARGV.shift)
  case arg
  when /--debug/
    $debug = true
  when /--mongo/
    mongo = ARGV.shift
  when /--(druby)|(uri)|(ucome)/
    druby = ARGV.shift
  else
    usage()
  end
end

if __FILE__ == $0
  DRb.start_service(druby, Ucome.new(mongo))
  puts DRb.uri
  DRb.thread.join
else
  puts "debug mode(pry?)"
end
