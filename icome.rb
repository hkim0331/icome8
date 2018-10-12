#!/usr/bin/env jruby
# coding: utf-8

require 'date'
require 'drb'
require 'socket'
require_relative 'icome-common'
require_relative 'icome-ui'

def usage_exit(s)
  print <<EOU
#{s}
usage:
$ icome [--version] [--debug] [--ucome druby://ucome_ip:port]
EOU
  exit(1)
end

class Icome

  def debug(s)
    puts "debug: #{s}" if @debug
  end

  def initialize(ucome, debug_flag)
    @ucome = ucome
    @debug = debug_flag
    @myip = IPSocket::getaddress(Socket::gethostname)
    @uid = ENV['USER']
    @sid = uid2sid(@uid)
    @icome8_dir = File.expand_path(@debug? "~/Desktop/dot-icome8" : "~/.icome8")
    Dir.mkdir(@icome8_dir) unless Dir.exist?(@icome8_dir)
    @ui = UI.new(self, @debug)
  end

  def icome
    unless @debug or c_2b?(@myip) or c_2g?(@myip)
      display("from: #{@myip}<br>教室外からできません。")
      return
    end

    term  = this_term()
    now   = Time.now
    today = now.strftime("%F")
    uhour = uhour(now)
    #
    # MUST ADJUST annually
    #
    debug "term: #{term} uhour: #{uhour}"
    unless @debug
      if (term =~ /q[12]/ and uhour !~ /(wed1)|(wed2)/i) or
        (term =~ /q[34]/ and uhour !~ /(tue2)|(thu1)|(thu4)|(fri4)/i)
        display("授業時間じゃありません。")
        return
      end
    end

    # BUG
    records = @ucome.find_date_ip(@sid, uhour)
    debug records.to_s
    if records.empty?
      if @ui.query?("#{uhour} を受講しますか？")
        debug [@sid, uhour, today, @myip].to_s
        @ucome.icome(@sid, uhour, today, @myip)
        debug "inserted"
      else
        return
      end
    else
      if records.map{|r| r.first}.include?(today)
        display("出席記録は一回の授業にひとつです。")
        return
      end
      @ucome.icome(@sid, uhour, today, @myip)
    end
    display("出席を記録しました。<br>" +
            "学生番号:#{@sid}<br>端末番号:#{@myip.split(/\./)[3]}")
    memo(uhour, now.strftime("%F %T"), @myip)
  end

  def show
    uhours = find_uhours_from_memo()
    if uhours.empty?
      display("記録がありません。")
    else
      if uhours.count == 1
        uhour = uhours[0]
      else
        uhour = uhours[@ui.option_dialog(uhours,
                                         "複数のクラスを受講しているようです。")]
      end
      display("日付:座席<br>" +
              @ucome.find_date_ip(@sid, uhour).
                map{|x| "#{x[0]}:#{x[1].split(/\./)[3]}"}.join('<br>'))
    end
  end

  # FIXME: メソッド名は personal_ex がいいと思う。
  def personal_ex()
    ret = @ucome.personal_ex(@sid)
    if ret.empty?
      display("秘密裡に抜きます。<br>"+
              "ファイルを指定した名前でセーブすること。<br>"+
              "間違うと回収できないよ。")
    else
      display(ret.sort.join("<br>"))
    end
  end

  # FIXME: object_id から日付を取り出せないか？
  def group_ex()
    ret = @ucome.group_ex(@sid)
    if ret.empty?
      display("提出物が見当たりません。")
    else
      display(ret.join("<br>"))
    end
  end

  # improve-menu
  def firefox_recover()
    if File.exists?("/usr/bin/firefox")
      system("kill `pidof firefox`")
      system("find ~/.mozilla/firefox -name lock -exec rm {} \\;")
      system("find ~/.mozilla/firefox -name .parentlock -exec rm {} \\;")
      system("/usr/bin/firefox &")
      display("firefox を再起動しました。<br>これでダメなら hkimura を呼ぼう。")
    else
      display("情報センターでしか効きません。")
    end
  end

  def lpcxpresso_recover()
    system("find ~/LPCXresso/workspace -name .lock -exec rm {} \\;")
    display("lpcxpresso & してみよう。ダメなら hkimura を呼ぶしか。")
  end

  def quit
    java.lang.System.exit(0)
  end

  # FIXME. デバッグ時と一貫して
  def memo(uhour, date_time, ip)
    name = File.join(@icome8_dir, "#{collection()}_#{uhour}")
    File.open(name, "a") do |fp|
      fp.puts "#{date_time} #{ip}"
    end
  end

  def find_uhours_from_memo()
    col="#{collection()}"
    Dir.entries(@icome8_dir).
      find_all{|x| x =~ /^#{col}/}.map{|x| x.split(/_/)[2]}
  end

  # rename as ucome_to_isc?
  def download(remote, local)
    if @debug
      puts "#{__method__} #{remote}, #{local}"
      puts "not yet implemented"
    end
  end

  # rename as isc_to_ucome?
  def upload(file)
    path = File.join(ENV['HOME'], file)
    if File.exists?(path) and File.size(path) < MAX_UPLOAD_SIZE
      puts "will upload #{file}" if @debug
      @ucome.upload(@sid, File.basename(file), File.open(path).read)
      puts "done" if @debug
    else
      display "#{file} is missing or too big."
    end
  end

  def exec(command)
    system(command)
  end

  def xcowsay(s)
    system("xcowsay --at=200,100 '#{s}'")
  end

  def has_xcowsay?()
    File.exists?("/edu/bin/xcowsay") or File.exists?("/usr/games/xcowsay")
  end

  def display(s)
    if has_xcowsay?()
      xcowsay(s.gsub(/<br>/,"\n"))
    else
      @ui.dialog(s)
    end
  end

  def start
    puts "start" if @debug
    Thread.new do
      i = 0
      while true do
        sleep INTERVAL
        cmd = @ucome.fetch(i)
        if cmd.nil?
          puts "cmd is nil" if @debug
        else
          puts "cmd: #{cmd}"if @debug
          i += 1
          if cmd[:status] == :enable
            case cmd[:command]
            when /^xcowsay\s+(.+)$/
              xcowsay($1)
            when /^dialog\s+(.+)$/
              @ui.dialog($1)
            when /^display\s+(.+)$/
              display($1)
            when /^upload\s+(\S+)/
              upload($1)
            when /^download\s+(\S+)\s+(\S+)$/
              download($1,$2)
            when /^exec/
              self.exec cmd[:command].sub(/^exec\s*/,'')
            when /^reset (\d+)/
              i = $1.to_i
            else
              puts "error: #{cmd}"
            end
          end
        end
      end
    end
  end

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
    ucome = UCOME
  when /--(druby)|(ucome)/
    ucome = ARGV.shift
  when /--version/
    puts VERSION
    exit(1)
  else
    usage_exit("unkown option: #{arg}")
  end
end

DRb.start_service
if debug
  puts "注意:150.69.0.0/16 以外から ucome 接続できないよ。"
  puts "ucome: #{ucome}"
end
icome = Icome.new(DRbObject.new(nil, ucome), debug)
icome.start
DRb.thread.join
