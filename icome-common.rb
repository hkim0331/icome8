# coding: utf-8
APP_NAME="icome8"
VERSION="1.8.5"
UPDATE="2018-10-12"

MONGO='mongodb://127.0.0.1:27017/ucome'
# this for development. is it good?
#UCOME='druby://127.0.0.1:4002'
UCOME='druby://150.69.90.3:4002'

INTERVAL = 3
MAX_UPLOAD_SIZE  = 5000000

# s never exists. isc vanished.
PREFIX = {'j' => '10', 'k' => '11', 'm' => '12', 'n' => '13',
          'o' => '14', 'p' => '15', 'q' => '16', 'r' => '17' }

def try_first(files)
  while file = files.shift
    return file if File.exists?(file)
  end
  ""
end

GTYPIST_CHECK = try_first(
  ["/edu/bin/gtypist-check.rb", "./bin/gtypist-check.rb"])

SID_UID_JNAME = try_first(
  ["/edu/lib/robocar/sid-uid-jname.txt",
   "/Users/hkim/workspace/robocar/data/sid-uid-jname.txt",
   "/home/hkim/workspace/robocar/data/sid-uid-jname.txt"])

def uid2jname(u)
    File.foreach(SID_UID_JNAME) do |line|
      sid,uid,jname = line.chomp.split(/ /, 3)
      if u == uid
        return jname
      end
    end
    #    return "an not find uid: #{u}"
    return ""
end

def uid2sid(uid)
  PREFIX[uid[0]] + uid[1,6]
rescue
  uid
end

def hour(time)
  return 1 if "08:50:00" <= time and time <= "10:20:00"
  return 2 if "10:30:00" <= time and time <= "12:00:00"
  return 3 if "13:00:00" <= time and time <= "14:30:00"
  return 4 if "14:40:00" <= time and time <= "16:10:00"
  return 5 if "16:20:00" <= time and time <= "17:50:00"
  return 0
end

def uhour(time)
  time.strftime("%a") + hour(time.strftime("%T")).to_s
end

def this_term()
  month = Time.now.month
  if 4<=month && month <=9
    "q1"
  else
    "q3"
  end
end

# academic year. used by ucome only.
def a_year()
  now = Time.now
  if now.month < 4
    now.year - 1
  else
    now.year
  end
end

# alias?
def term_year()
  collection()
end

def collection()
  "#{this_term()}_#{a_year()}"
end

# FIXME, not smart.
def linux?()
  ENV['HOME'] =~ /^\/home/
end

def osx?()
  ENV['HOME'] =~ /^\/User/
end

def c_2b?(ip)
  ip =~ /^10\.27\.100\.\d+/
end

def c_2g?(ip)
  ip =~ /^10\.27\.102\.\d+/
end

#def remote_t?(ip)
#  ip =~ /^10\.27\.104\.1$/
#end
