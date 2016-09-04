# coding: utf-8
module Gtypist
#  require './icome-dialog'
#  include Dialog

  def gtypist(pat)
    ret=[]
    File.foreach("#{ENV['HOME']}/.gtypist") do |line|
      if line =~ /#{pat}/
        ret.push "#{line.chomp}<br>"
      end
    end
    dialog(ret.join)
  end

  def gtypist_all()
    ret=[]
    IO.popen("/home/t/hkimura/bin/gtypist-check.rb") do |p|
      ret = p.readlines.map{|l| l.chomp}
    end
    dialog(ret.join('<br>'))
  end

  def gtypist_stage(s)
    ret = []
    len = {'Q1' => 8, 'Q2' =>  8, 'Q3' => 10, 'Q4' => 11, 'Q5' => 9}
    IO.popen("/home/t/hkimura/bin/gtypist-check.rb") do |p|
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

end
