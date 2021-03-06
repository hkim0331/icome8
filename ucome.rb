#!/usr/bin/env ruby
# coding: utf-8

require 'mongo'
require 'drb'
require 'socket'
require 'logger'
require_relative 'icome-common'

ROBOCAR = "rb_2018"
ANSWERS = "as_2018"

def usage()
  print <<EOF
ucome #{VERSION}
usage:
$ ucome [--debug]
        [--mongodb mongodb://server:port/db]
        [--ucome druby://my_ip_address:port]

default:

EOF
  exit(1)
end

class Ucome
  attr_reader :reset_count

  def debug(s)
    puts
    puts s if @debug
    puts
  end

  def initialize(mongo, debug_flag)
    @debug = false
    if debug_flag
      @debug   = true
      @upload  = "./upload"
      @logger  = Logger.new(STDERR)
    else
      @upload  = "/srv/ucome/upload"
      @logger  = Logger.new("/srv/ucome/log/ucome.log", 5, 10*1024)
    end

    @logger.level = Logger::DEBUG

    # determin mongodb collection from launch time info.
    @mongo = mongo
    @ds = Mongo::Client.new(@mongo, logger: @logger)
    @col = @ds[collection()]
    @commands = []
    @cur = 0
    @next = -1
  end

  def icome(sid, uhour, date, ip)
    info= {sid: sid, uhour: uhour, date: date, ip: ip}
    debug "icome " + info.to_s
    @col.insert_one(info)
  end

  #@col.find() returns a View instance.
  def find_date_ip(sid, uhour)
    debug "find_date_ip " + sid + " " + uhour
    @col.find({sid: sid, uhour: uhour}, {date: 1, ip: 1}).
      map{|x| [x[:date], x[:ip]]}
  end

  # 個人課題の提出状況。
  # アップロード先は ucome の動くサーバなので、
  # icome の動いているローカル PC では解決できない。
  def personal_ex(sid)
    dir = File.join(@upload, sid)
    if File.directory?(dir)
      Dir.entries(dir).delete_if{|x| x=~ /^\./}
    else
      []
    end
  end

  # FIXME, ダサい。データベースの設計がまずいのが原因か。
  def sid2gid(sid)
    if ret = @ds[ROBOCAR].find({status: 1, m1: sid}).first
      ret[:gid]
    elsif ret = @ds[ROBOCAR].find({status: 1, m2: sid}).first
      ret[:gid]
    elsif ret = @ds[ROBOCAR].find({status: 1, m3: sid}).first
      ret[:gid]
    else
      nil
    end
  end

  def group_ex(sid)
    gid = sid2gid(sid)
    if gid.nil?
      ["グループが見つからないよ。"]
    else
      ret = @ds[ANSWERS].find({gid: gid}, {num: 1}).
              map{|x| x[:num]}
      [ "gid #{gid}:"] + ret
    end
  end

  #
  # icome methods
  #

  # if not found, return nil.
  def fetch(n)
    @commands[n]
  end

  # %F_#{save_as} は並び順のため。
  def upload(sid, save_as, contents)
    @logger.debug "upload from #{sid}, save as #{save_as}"
    dir = File.join(@upload, sid)
    Dir.mkdir(dir) unless File.directory?(dir)
    to = File.join(dir, Time.now.strftime("%F_#{save_as}"))
    File.open(to, "w") do |f|
      f.puts contents
    end
  rescue
    @logger.warn "can not mkdir #{dir}"
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

  # for checking ucome availability
  def ping(ip)
    @logger.debug("ping from #{ip}")
    "pong"
  end

end

#
# main starts here.
#
debug = (ENV['DEBUG'] || false)
ucome = (ENV['UCOME'] || UCOME)
mongo = (ENV['MONGO'] || MONGO)

while (arg = ARGV.shift)
  case arg
  when /--debug/
    debug = true
  when /--mongo/
    mongo = ARGV.shift
  when /--(druby)|(ucome)/
    ucome = ARGV.shift
  else
    usage()
  end
end

if __FILE__ == $0
  DRb.start_service(ucome, Ucome.new(mongo, debug))
  if debug
    puts "ucome: #{ucome}"
  end
  DRb.thread.join
else
  puts "REPL debug mode. using irb?"
end
