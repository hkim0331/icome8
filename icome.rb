#!/usr/bin/env jruby
# coding: utf-8

require 'date'
require 'drb'
require 'socket'
require_relative 'icome-common'
require_relative 'icome-ui'

def usage
  print <<EOU
ucome #{VERSION}
# usage

$ ucome [--debug] [--ucome druby://ucome_ip:port]
EOU
  exit(1)
end

class Icome

  def initialize(ucome)
    @ip = IPSocket::getaddress(Socket::gethostname)
    unless $debug or c_2b?(@ip) or c_2b?(@ip)
      display("教室外から icome 出来ません。")
      sleep 3
      quit
    end
    @ucome = ucome
    @uid = ENV['USER']
    @sid = uid2sid(@uid)
    @icome8_dir = $debug ? "icome8" : File.expand_path("~/.icome8")
    Dir.mkdir(@icome8_dir) unless Dir.exist?(@icome8_dir)
  end

  def setup_ui
    @ui = UI.new(self, $debug)
  end

  def icome
    term  = this_term()
    now = Time.now
    today = now.strftime("%F")
    uhour = uhour(now)
    if $debug
      puts "#{term} #{today}  #{uhour}"
    else
      if (term =~ /q[12]/ and uhour !~ /(wed1)|(wed2)/i) or
        (term =~ /q[34]/ and uhour !~ /(tue2)|(tue4)|(thr1)|(thr4)/i)
        display("授業時間じゃありません。")
        return
      end
    end
    records = @ucome.find_icome(@sid, uhour)
    if records.empty?
      if @ui.query?("#{uhour} を受講しますか？")
        @ucome.create(@sid, @uid, uhour)
        @ucome.update(@sid, uhour, today, @ip)
      end
    else
      if records.include?(today)
        display("出席記録は一回の授業にひとつです。")
        return
      else
        @ucome.update(@sid, uhour, today, @ip)
        display("出席を記録しました。<br>" +
                "学生番号:#{@sid}<br>端末番号:#{@ip.split(/\./)[3]}")
      end
    end
    memo(uhour, now.strftime("%F %T"))
  end

  def show
    uhours = find_uhours_from_memo()
    if uhours.empty?
      display("記録がありません。")
    else
      if uhours.count == 1
        uhour = uhours[0]
      else
        uhour = uhours[@ui.option_dialog(uhours, "複数のクラスを受講しているようです。")]
      end
      display(@ucome.find_icome(@sid, uhour).sort.join('<br>'))
    end
  end

  # 個人課題、提出状況は ucome に聞かないと。
  def personal()
    ret = @ucome.personal(@sid)
    if ret.empty?
      display("まだありません。")
    else
      display(ret.sort.join("<br>"))
    end
  end

  def quit
    java.lang.System.exit(0)
  end

  def memo(uhour, date_time)
    name = File.join(@icome8_dir, "#{collection()}_#{uhour}")
    File.open(name, "a") do |fp|
      fp.puts date_time
    end
  end

  def find_uhours_from_memo()
    col="#{collection()}"
    Dir.entries(@icome8_dir).
      find_all{|x| x =~ /^#{col}/}.
      map{|x| x.split(/_/)[2]}
  end

  # rename as ucome_to_isc?
  def download(remote, local)
    puts "#{__method__} #{remote}, #{local}" if $debug
  end

  # rename as isc_to_ucome?
  def upload(local)
    it = File.join(ENV['HOME'], local)
    if File.exists?(it)
      if File.size(it) < MAX_UPLOAD_SIZE
        @ucome.upload(@sid, File.basename(local), File.open(it).read)
      else
        display("too big: #{it}: #{File.size(it)}")
      end
    else
      display("ファイルがありません。#{it}")
    end
  end

  def exec(command)
    system(command)
  end

  def xcowsay(s)
    puts "s:#{s}"
    system("xcowsay --at=200,100 '#{s}'")
  end

  def display(s)
    if linux?()
      xcowsay(s.gsub(/<br>/,"\n"))
    else
      @ui.dialog(s)
    end
  end

  def start
    puts "start" if $debug
    Thread.new do
      i = 0
      while true do
        cmd = @ucome.fetch(i)
        unless cmd.nil?
          i += 1
          if cmd[:status] == :enable
            puts "cmd: #{cmd}"
            case cmd[:command]
            when /xcowsay\s+(.+)$/
              xcowsay($1)
            when /dialog\s+(.+)$/
              @ui.dialog($1)
            when /^display\s+(.+)$/
              display($1)
            when /^upload\s+(\S+)/
              upload($1)
            when /^download\s+(\S+)\s+(\S+)$/
              download($1,$2)
            when /^exec/
              system(cmd.sub(/^exec\s*/,''))
            when /^reset (\d+)/
              i = $1.to_i
            else
              puts "error: #{cmd}"
            end
          end
        end
        sleep INTERVAL
      end
    end
  end

end

#
# main starts here
#
$debug =(ENV['DEBUG'] || false)
ucome = (ENV['UCOME'] || UCOME)

while (arg = ARGV.shift)
  case arg
  when /--debug/
    $debug = true
  when /--(druby)|(uri)|(ucome)/
    ucome = ARGV.shift
  else
    usage()
  end
end

puts ucome if $debug
DRb.start_service
icome = Icome.new(DRbObject.new(nil, ucome))
icome.setup_ui
icome.start
DRb.thread.join
