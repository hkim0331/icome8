#!/usr/bin/env jruby
# coding: utf-8

require 'date'
require 'drb'
require 'socket'
require_relative 'icome-common'
require_relative 'icome-ui'

 def usage
  print <<EOU
icome #{VERSION}
# usage

$ icome [--debug] [--ucome druby://ucome_ip:port]

EOU
  exit(1)
end

class Icome

  def initialize(ucome)
    begin
     ucome.ping
    rescue
      puts "ucome does not respond. will quit."
      quit
      DRb.thread.join
    end
    puts "debug mode" if $debug
    @ui = UI.new(self, $debug)
    @ip = IPSocket::getaddress(Socket::gethostname)
    unless $debug or c_2b?(@ip) or c_2g?(@ip) or remote_t?(@ip)
      display("#{@ip}<br>教室外から icome 出来ません。<br>さようなら。")
      quit
      DRb.thread.join
    end
    @ucome = ucome

    @uid = ENV['USER']
    @sid = uid2sid(@uid)

    # under construction 2016-10-10
    #    @gid =
    #

    # FIXME:
    # これだと isc で DEBUG=1 icome した時、~/icome フォルダを作ってしまう。
    # デバッグモードなので、まあいいやできるレベルだが。
    @icome8_dir = $debug ? "icome8" : File.expand_path("~/.icome8")
    #
    Dir.mkdir(@icome8_dir) unless Dir.exist?(@icome8_dir)
  end

  def icome
    term  = this_term()
    now = Time.now
    today = now.strftime("%F")
    uhour = uhour(now)
    if $debug
      puts "#{term} #{today} #{uhour}"
    else
      if (term =~ /q[12]/ and uhour !~ /(wed1)|(wed2)/i) or
        (term =~ /q[34]/ and uhour !~ /(tue2)|(tue4)|(thu1)|(thu4)/i)
        display("授業時間じゃありません。")
        return
      end
    end
    records = @ucome.find_date_ip(@sid, uhour)
    if records.empty?
      if @ui.query?("#{uhour} を受講しますか？")
        puts "will call @ucome.insert" if $debug
        @ucome.insert(@sid, uhour, today, @ip)
      # FIXME: ここで myid を付与したい。面倒か？
      #@ucome.create_myid(@sid, @uid)
      else
        return
      end
    else
      if records.map{|r| r.first}.include?(today)
        display("出席記録は一回の授業にひとつです。")
        return
      else
        @ucome.insert(@sid, uhour, today, @ip)
      end
    end
    display("出席を記録しました。<br>" +
            "学生番号:#{@sid}<br>端末番号:#{@ip.split(/\./)[3]}")
    memo(uhour, now.strftime("%F %T"), @ip)
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

<<<<<<< HEAD
  # 個人課題、提出状況は ucome に聞かないと。
  def personal_assignments()
    ret = @ucome.personal_assignments(@sid)
=======
  # FIXME: メソッド名は personal_ex がいいと思う。
  def personal()
    ret = @ucome.personal(@sid)
>>>>>>> master
    if ret.empty?
      display("秘密裡に抜きます。<br>ファイルを指定した名前でセーブすること。<br>"+
             "間違うと回収できないよ。")
    else
      display(ret.sort.join("<br>"))
    end
  end

<<<<<<< HEAD
  def group_assignments()
    ret = @ucome.group_assignments(@gid)
    display("授業資料の「グループ課題提出」から提出すること。")
=======
  # FIXME: object_id から日付を取り出せないか？
  def group_ex()
    ret = @ucome.group_ex(@sid)
    if ret.empty?
      display("提出物が見当たりません。")
    else
      display(ret.join("<br>"))
    end
>>>>>>> master
  end

  def quit
    java.lang.System.exit(0)
  end

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
      # 表示するとめんどくさいか？ 「もう一度取ってください」とか。
      display("ファイルがありません。#{it}")
    end
  end

  def exec(command)
    system(command)
  end

  def xcowsay(s)
    system("xcowsay --at=200,100 --reading-speed=1000 '#{s}'")
  end

  def display(s)
    puts "display: #{s}" if $debug
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
        sleep INTERVAL
        cmd = @ucome.fetch(i)
        puts cmd if $debug and (not cmd.nil?)
        unless cmd.nil?
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
icome.start
DRb.thread.join
