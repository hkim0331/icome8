#!/usr/bin/env jruby
# coding: utf-8
require './icome-dialog'
require './icome-gtypist'
include Dialog
include Gtypist

EXAM_URI = "http://literacy-2016.melt.kyutech.ac.jp/fcgi/abb2.cgi"

class UI
  include Java
  include_package 'java.awt'
  include_package 'javax.swing'

  def initialize(icome, debug)
    @icome = icome
    @debug = debug

    frame = JFrame.new(APP_NAME)
    if @debug
      frame.set_default_close_operation(JFrame::EXIT_ON_CLOSE)
    else
      frame.set_default_close_operation(JFrame::DO_NOTHING_ON_CLOSE)
    end

    menu = JPanel.new
    menu.set_layout(BoxLayout.new(menu, BoxLayout::Y_AXIS))

    menu.add(common_menu)

    case this_term()
    when /(q1)|(q2)/
      menu.add(gtypist_menu)
    when /(q3)|(q4)/
      menu.add(robocar_menu)
    end

    frame.add(menu)
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

    button = JButton.new("中間テスト") do |s|
      button.add_action_listener do |e|
        if @debug
          system("open #{EXAM_URI} &")
        else
          system("/usr/bin/firefox #{EXAM_URI} &")
        end
      end
    end
    panel.add(button)
    panel
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
