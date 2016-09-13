#!/usr/bin/env ruby
# coding: utf-8

require 'mongo'
require 'drb'
require 'socket'
require 'logger'
require_relative 'icome-common'

def usage()
  print <<EOF
ucome #{VERSION}

# usage:

$ ucome [--debug]
        [--mongodb mongodb://server:port/db]
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
    # determin mongodb collection from launch time info.
    @mongo = mongo
    @cl = Mongo::Client.new(@mongo, logger: logger)[collection()]
    @commands = []
    @cur = 0
    @next = -1
  end

  #
  # mongodb interface
  #
  def create(sid, uid, uhour)
    @cl.insert_one({sid: sid, uid: uid, uhour: uhour, icome: []})
  end

  def update(sid, uhour, date, ip)
    @cl.update_one({sid: sid, uhour: uhour},
                   {"$addToSet" => {icome: [date, ip]}})
  end

  def find_icome(sid, uhour)
    ret = @cl.find({sid: sid, uhour: uhour})
    # CHECK: should return false?
    if ret.first.nil?
      []
    else
      ret.first[:icome]         # returns [[date1,ip1],[date2,ip2,...]]
    end
  end

  def insert(sid, uhour, date, ip)
    @cl.insert_one({sid: sid, uhour: uhour, date: date, ip: ip})
  end

  #@cl.find() returns a View instance.
  def find_date_ip(sid, uhour)
    @cl.find({sid: sid, uhour: uhour}, {date: 1, ip: 1}).
      map{|x| [x[:date],x[:ip]]}
  end

  # 個人課題の提出状況。
  # アップロード先は ucome の動くサーバなので、
  # icome の動いているローカル PC では解決できない。
  def personal(sid)
    dir = File.join(@upload, sid)
    if File.directory?(dir)
      Dir.entries(dir).delete_if{|x| x=~ /^\./}
    else
      []
    end
  end

  #
  # icome methods
  #

  # if not found, return nil.
  def fetch(n)
    #puts "fetch" if $debug
    @commands[n]
  end

  # %F_#{save_as_name} は並び順のため。
  # CHECK: contents?
  def upload(sid, save_as, contents)
    dir = File.join(@upload, sid)
    Dir.mkdir(dir) unless File.directory?(dir)
    to = File.join(dir, Time.now.strftime("%F_#{save_as}"))
    File.open(to, "w") do |f|
      f.puts contents
    end
  end

  def download(file, save_as)

  end

  #
  # acome methods
  #
  def mongo
    @mongo
  end
  
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

  def enable(n)
    @commands[n][:status] = :enable
  end

  def disable(n)
    @commands[n][:status] = :disable
  end

  def clear
    @commands = []
  end

end

#
# main starts here.
#
$debug = (ENV['DEBUG'] || false)
druby  = (ENV['UCOME'] || UCOME)
mongo  = (ENV['MONGO'] || MONGO)

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
  puts "druby: #{druby} mongo:#{mongo}"
  DRb.start_service(druby, Ucome.new(mongo))
  puts DRb.uri
  DRb.thread.join
else
  puts "debug mode(pry?)"
end
