#!/usr/bin/env jruby
# coding: utf-8
require './icome-dialog'
include Dialog

class UI
  include Java
  include_package 'java.awt'
  include_package 'javax.swing'
#  require './icome-gtypist'
#  include Gtypist

  def initialize(icome, debug)
    @icome = icome
    @debug = debug

    frame = JFrame.new(APP_NAME)
    if @debug
      frame.set_default_close_operation(JFrame::EXIT_ON_CLOSE)
    else
      frame.set_default_close_operation(JFrame::DO_NOTHING_ON_CLOSE)
    end

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

    case this_term()
    when /(q1)|(q2)/
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

      button = JButton.new("中間テスト") do |s|
        button.add_action_listener do |e|
          system("firefox http://literacy-2016.melt.kyutech.ac.jp/fcgi/abb2.cgi &")
        end
      end
      panel.add(button)

    when /(q3)|(q4)/
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

      # quit button in development only.
      if @debug
        button = JButton.new('Quit')
        button.add_action_listener do |e|
          @icome.quit
        end
        panel.add(button)
      end
    else
#      raise "runtime error: #{this_term()}"
    end

    frame.add(panel)
    frame.pack
    frame.set_visible(true)
  end

end
