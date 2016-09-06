# coding: utf-8
class UI
  include Java
  import javax.swing.JFrame
  import javax.swing.JButton
  import javax.swing.JPanel
  import javax.swing.BoxLayout
  import javax.swing.JOptionPane
  # include Java
  # include_package 'java.awt'
  # include_package 'javax.swing'

  attr_accessor :menu

  def dialog(s)
    JOptionPane.showMessageDialog(nil, "<html>#{s}</html>", "icome",
                                  JOptionPane::INFORMATION_MESSAGE)
  end

  def query?(s)
    ans = JOptionPane.showConfirmDialog(nil, "<html>#{s}</html>", "icome",
                                        JOptionPane::YES_NO_OPTION)
    ans == JOptionPane::YES_OPTION
  end

  def option_dialog(ss, query)
    ans = JOptionPane.showOptionDialog(nil,"<html>#{query}</html>", "icome",
                                       JOptionPane::YES_NO_OPTION,
                                       JOptionPane::QUESTION_MESSAGE,
                                       nil, ss, ss[0])
  end

  def initialize(icome, debug)
    @icome = icome
    @debug = debug

    frame = JFrame.new(APP_NAME)
    frame.set_default_close_operation(JFrame::DO_NOTHING_ON_CLOSE)

    @menu = JPanel.new
    @menu.set_layout(BoxLayout.new(menu, BoxLayout::Y_AXIS))
    @menu.add(common_menu)

    if @debug
      @menu.add(gtypist_menu)
      @menu.add(robocar_menu)
    else
      case this_term()
      when /(q1)|(q2)/
        @menu.add(gtypist_menu)
      when /(q3)|(q4)/
        @menu.add(robocar_menu)
      end
    end

    frame.add(@menu)
    frame.pack
    frame.set_visible(true)
  end

  def common_menu
    panel = JPanel.new
    panel.set_layout(BoxLayout.new(panel, BoxLayout::Y_AXIS))

    button = JButton.new('出席を記録する')
    button.add_action_listener do |e|
      @icome.icome
    end
    panel.add(button)

    button = JButton.new('出席記録を見る')
    button.add_action_listener do |e|
      @icome.show
    end
    panel.add(button)

    if @debug
      button = JButton.new('Quit')
      button.add_action_listener do |e|
        @icome.quit
      end
      panel.add(button)
    end
    panel
  end

  def gtypist_menu
    panel = JPanel.new
    panel.set_layout(BoxLayout.new(panel, BoxLayout::Y_AXIS))

    button = JButton.new('5/18 gtypist')
    button.add_action_listener do |e|
      gtypist('May 18')
    end
    panel.add(button)

    %w{Q1 Q2 Q3 Q4 Q5}.each do |s|
      button = JButton.new("gtypist #{s}")
      button.add_action_listener do |e|
        gtypist_stage(s)
      end
      panel.add(button)
    end

    button = JButton.new("中間テスト")
    uri = "http://literacy-2016.melt.kyutech.ac.jp/fcgi/abb2.cgi"
    button.add_action_listener do |e|
      open = @debug ? "open" : "/usr/bin/firefox"
      system("#{open} #{uri} &")
    end
    panel.add(button)

    panel
  end

  def gtypist(pat)
    gtypist = "#{ENV['HOME']}/.gtypist"
    if File.exists?(gtypist)
      ret = []
      File.foreach(gtypist) do |line|
        if line =~ /#{pat}/
          ret.push "#{line.chomp}<br>"
        end
      end
      dialog(ret.join)
    else
      dialog("do gtypist!")
    end
  end

  def gtypist_all()
    ret = []
    IO.popen("./bin/gtypist-check.rb") do |p|
      ret = p.readlines.map{|l| l.chomp}
    end
    dialog(ret.join('<br>'))
  end

  def gtypist_stage(s)
    ret = []
    len = {'Q1' => 8, 'Q2' =>  8, 'Q3' => 10, 'Q4' => 11, 'Q5' => 9}
    IO.popen("./bin/gtypist-check.rb") do |p|
      ret = p.readlines.map{|l| l.chomp}.find_all{|l| l =~ /#{s}/}
    end
    greeting = ""
    if ret.length >= len[s]
      greeting = "<p style='color:red;'>CLEAR!!</p>"
    elsif ret.length == 0
      greeting = "<p style='color:blue;'>やっとかないと平常点つかない。</p>"
    end
    dialog(ret.join('<br>') + greeting)
  end

  def robocar_menu
    panel = JPanel.new
    panel.set_layout(BoxLayout.new(panel, BoxLayout::Y_AXIS))

    button = JButton.new('個人課題')
    button.add_action_listener do |e|
      @icome.personal
    end
    panel.add(button)

    button = JButton.new('グループ課題')
    button.add_action_listener do |e|
      dialog("授業資料の「グループ課題提出」から提出すること。")
    end
    panel.add(button)
    panel
  end

end
