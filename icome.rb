#!/usr/bin/env jruby
# coding: utf-8

require 'date'
require 'drb'
require 'socket'
require './icome-common'
require './icome-ui'

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
    puts "debug is on" if $debug
    @ucome = ucome
    @sid = uid2sid(ENV['USER'])
    @ip = IPSocket::getaddress(Socket::gethostname)
    @icome8_dir = if $debug
                    "icome8"
                  else
                    File.expand_path("~/.icome8")
                  end
    Dir.mkdir(@icome8_dir) unless Dir.exist?(@icome8_dir)
    @record = nil
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
      puts "term: #{term}"
      puts "today: #{today}"
      puts "uhour: #{uhour}"
    else
      if (term =~ /q[12]/ and uhour !~ /(wed1)|(wed2)/i) or
        (term =~ /q[34]/ and uhour !~ /(tue2)|(tue4)|(thr1)|(thr4)/i)
        @ui.dialog("授業時間じゃありません。")
        return
      end
    end
    records = @ucome.find_icome(@sid, uhour)
    if records.empty?
      if @ui.query?("#{uhour} を受講しますか？")
        @ucome.create(@sid, uhour)
        @ucome.update(@sid, uhour, today, @ip)
      end
    else
      if (not $debug) and records.include?(today)
        @ui.dialog("出席記録は一回の授業にひとつで十分。")
        return
      else
        @ucome.update(@sid, uhour, today, @ip)
        @ui.dialog("出席を記録しました。<br>" +
                   "学生番号:#{@sid}<br>端末番号:#{@ip.split(/\./)[3]}")
      end
    end
    memo(term, uhour, now.strftime("%F %T"))
  end

  def show
    uhours = find_uhours_from_memo(this_term())
    if uhours.empty?
      @ui.dialog("記録がありません。")
    else
      if uhours.count == 1
        uhour = uhours[0]
      else
        uhour = uhours[@ui.option_dialog(uhours, "複数のクラスを受講しているようです。")]
      end
      @ui.dialog(@ucome.find_icome(@sid, uhour).sort.join('<br>'))
    end
  end

  # 個人課題,
  def personal()
    ret = @ucome.personal(@sid)
    if ret.empty?
      @ui.dialog("まだありません。")
    else
      @ui.dialog(ret.sort.join("<p>"))
    end
  end

  def quit
    java.lang.System.exit(0) unless ENV['UCOME']
  end

  def memo(term, uhour, date_time)
    File.open(File.join(@icome8_dir, "#{term}_#{uhour}"), "a") do |fp|
      fp.puts date_time
    end
  end

  def find_uhours_from_memo(term)
    Dir.entries(@icome8_dir).find_all{|x| x =~ /^#{term}/}.map{|x| x.split(/_/)[1]}
  end

  # FIXME: rename as ucome_to_isc?
  def download(remote, local)
    puts "#{__method__} #{remote}, #{local}" if $debug
  end

  # FIXME: rename as isc_to_ucome?
  def upload(local)
    it = File.join(ENV['HOME'], local)
    if File.exists?(it)
      if File.size(it) < MAX_UPLOAD_SIZE
        @ucome.upload(@sid, File.basename(local), File.open(it).read)
      else
        @ui.dialog("too big: #{it}: #{File.size(it)}")
      end
    else
      # CHECK そんなことあるか？
      # FIXME 日本語メッセージだと表示されない。
      @ui.dialog("ファイルがありません。#{it}")
    end
  end

  def exec(command)
    system(command)
  end

  def xcowsay(s)
    if ENV['HOME'] =~ /^\/home/
      system("xcowsay --at=400,400 #{s}")
    else
      @ui.dialog(s + "(use display instead)")
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
            when /^display\s+(.+)$/
              @ui.dialog($1)
            when /^upload\s+(\S+)/
              upload($1)
            when /^download\s+(\S+)\s+(\S+)$/
              download($1,$2)
            when /^exec/
              system(cmd.sub(/^exec\s*/,''))
            when /^reset (\d+)/
              i = $1.to_i
            else
              debug "error: #{cmd}"
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
$debug =(ENV['DEBUG'] ||  false)
ucome = (ENV['UCOME'] || 'druby://127.0.0.1:9007')

while (arg = ARGV.shift)
  case arg
  when /--debug/
    $debug = true
    ucome = 'druby://127.0.0.1:9007'
  when /--(druby)|(uri)|(ucome)/
    ucome = ARGV.shift
  else
    usage()
  end
end

if __FILE__ == $0
  DRb.start_service
  icome = Icome.new(DRbObject.new(nil, ucome))
  icome.setup_ui
  icome.start
  DRb.thread.join
end
