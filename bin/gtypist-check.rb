#!/usr/bin/env ruby
# coding: utf-8
# check the completion status of level Q of gtypist.
# check S, also.

DEBUG = false

def usage
  print <<EOU
usage: #{__FILE__} gtypist_record
       #{__FILE__}

without arguments, works like #{__FILE__} $HOME/.gtypist
EOU
  exit(1)
end

def debug(s)
  puts s if DEBUG
end

def is_level?(l)
  l =~ /_(Q|S)_R_L\d+/
end

def is_errors(l)
  l =~ /errors/
end

def get_level(l)
  l =~ /(_(Q|S)_R_L\d+)/
  $1
end

def get_errors(l)
  l =~ /with (\d+\.\d+)% errors/
  $1.to_f
end

def get_date(l)
  l.split[1..3].join(' ')
end

#
# main starts here
#

if ARGV.count == 0
  infile = File.expand_path(File.join("~", ".gtypist"))
elsif ARGV.count == 1
  infile = ARGV[0]
else
  usage()
end

unless File.exists?(infile)
  puts "gtypist してる?"
  exit(1)
end

cleared = Hash.new("")
level = ""
File.foreach(infile) do |line|
  line = line.chomp
  if is_level?(line)
    level = get_level(line) #
  elsif is_errors(line) and get_errors(line) <= 3.0
    cleared[level] = get_date(line)
  end
end

# read-q.rb で読んだデータをマニュアルで加工。
levels = {
"_Q_R_L4" => "Q1(1)",
"_Q_R_L5" => "Q1(2)",
"_Q_R_L6" => "Q1(3)",
"_Q_R_L7" => "Q1(4)",
"_Q_R_L8" => "Q1(5)",
"_Q_R_L9" => "Q1(6)",
"_Q_R_L10" => "Q1(7)",
"_Q_R_L11" => "Q1(8)",
"_Q_R_L13" => "Q2(1)",
"_Q_R_L14" => "Q2(2)",
"_Q_R_L15" => "Q2(3)",
"_Q_R_L16" => "Q2(4)",
"_Q_R_L17" => "Q2(5)",
"_Q_R_L18" => "Q2(6)",
"_Q_R_L19" => "Q2(7)",
"_Q_R_L20" => "Q2(8)",
"_Q_R_L22" => "Q3(1)",
"_Q_R_L23" => "Q3(2)",
"_Q_R_L24" => "Q3(3)",
"_Q_R_L25" => "Q3(4)",
"_Q_R_L26" => "Q3(5)",
"_Q_R_L27" => "Q3(6)",
"_Q_R_L28" => "Q3(7)",
"_Q_R_L29" => "Q3(8)",
"_Q_R_L30" => "Q3(9)",
"_Q_R_L31" => "Q3(9)",
"_Q_R_L34" => "Q4(1)",
"_Q_R_L35" => "Q4(2)",
"_Q_R_L36" => "Q4(3)",
"_Q_R_L37" => "Q4(4)",
"_Q_R_L38" => "Q4(5)",
"_Q_R_L39" => "Q4(6)",
"_Q_R_L40" => "Q4(7)",
"_Q_R_L41" => "Q4(8)",
"_Q_R_L42" => "Q4(9)",
"_Q_R_L43" => "Q4(9)",
"_Q_R_L44" => "Q4(9)",
"_Q_R_L45" => "Q4(10)",
"_Q_R_L47" => "Q5(1)",
"_Q_R_L48" => "Q5(2)",
"_Q_R_L49" => "Q5(3)",
"_Q_R_L50" => "Q5(4)",
"_Q_R_L51" => "Q5(5)",
"_Q_R_L52" => "Q5(6)",
"_Q_R_L53" => "Q5(7)",
"_Q_R_L54" => "Q5(8)",
"_Q_R_L55" => "Q5(9)",
"_S_R_L2"  => "S1(1)",
"_S_R_L3"  => "S1(2)",
"_S_R_L4"  => "S1(3)",
"_S_R_L5"  => "S1(4)",
"_S_R_L6"  => "S1(5)"

}

cleared.each do |key, value|
  puts "#{levels[key]} #{value}" unless levels[key].nil?
end
