#!/usr/bin/env jruby
# coding: utf-8
#
# use swing. so jruby.

require 'date'
require 'drb'
require 'socket'
require './icome-common'
require './icome-ui'

class Icome
  attr_accessor :interval

  def initialize(ucome)
    @ucome = ucome
    @sid = uid2sid(ENV['USER'])
    @ip = IPSocket::getaddress(Socket::gethostname)
    @icome8_dir = File.expand_path("~/.icome8")
    Dir.mkdir(@icome8_dir) unless Dir.exist?(@icome8_dir)
    @record = nil
  end

  def setup_ui
    @ui = UI.new(self, $debug)
  end

  def icome
    term  = this_term()
    now   = Time.now
    uhour = uhour(now)
    today = now.to_s.split[0]
    unless $debug
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
      if records.include?(today)
        dialog("出席記録は一回の授業にひとつで十分。")
        return
      else
        @ucome.update(@sid, uhour, today)
        self.dialog("出席を記録しました。<br>学生番号:#{@sid}<br>端末番号:#{@ip.split(/\./)[3]}")
      end
    end
    memo(term, uhour, today)
  end

  def show
    uhours = find_uhours_from_memo(this_term())
    if uhours.empty?
      @ui.dialog("記録がありません。")
      return
    end
    if uhours.count == 1
      uhour = uhours[0]
    else
      ret = @ui.option_dialog(uhours, "複数のクラスを受講しているようです。")
      uhour = uhours[ret]
    end
    record = @ucome.find_icome(@sid, uhour)
    if record.empty?
      @ui.dialog("記録がありません。変ですね。")
    else
      @ui.dialog(record.sort.join('<br>'))
    end
  end

  # 個人課題
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

  def memo(term, uhour, today)
    File.open(File.join(@icome8_dir, "#{term}_#{uhour}"), "a") do |fp|
      fp.puts today
    end
  end

  def find_uhours_from_memo(term)
    Dir.entries(@icome8_dir).find_all{|x| x =~ /^#{term}/}.map{|x| x.split(/_/)[1]}
  end

  def start
    puts "start called"
    Thread.new do
      next_cmd = 0
      reset = 0
      while true do
        ucome_reset = @ucome.reset_count
        if ucome_reset > reset
          next_cmd = 0
          reset = ucome_reset
        end
        cmd = @ucome.fetch(next_cmd)
        debug "fetch:#{cmd}, reset: #{reset}, next_cmd: #{next_cmd}"
        if cmd.nil?
          puts "sleep"
          sleep INTERVAL
          next
        end

        case cmd
        when /^x*cowsay\s+(.+)$/
          cowsay($1)
        when /^display\s+(.+)$/
          @ui.dialog($1)
        when /^upload\s+(\S+)/
          upload($1)
        when /^download\s+(\S+)\s+(\S+)$/
          download($1,$2)
        when /^exec/
          exec(cmd)
        # BUG!
        when /reset (\d+)/
          next_cmd = $1.to_i
        else
          debug "error: #{cmd}"
        end
        next_cmd += 1
      end
    end
  end

  # FIXME: isc to isc? or ucome to isc?
  def download(remote, local)
    debug "#{__method__} #{remote}"
  end

  def upload(local)
    debug "upload #{local}"
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
      @ui.dialog("did not find #{it}.")
    end
  end


  def exec(command)
    system(command)
  end

  def cowsay(s)
    system("xcowsay --at=400,400 #{s}")
  end

end

#
# main starts here
#
$debug = false
ucome = (ENV['UCOME'] || 'druby://127.0.0.1:9007')
while (arg = ARGV.shift)
  case arg
  when /--debug/
    $debug = true
    ucome = 'druby://localhost:9007'
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

