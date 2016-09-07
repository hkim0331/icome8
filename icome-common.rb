APP_NAME="icome8"
VERSION="0.3"
UPDATE="2016-09-07"

MONGO='mongodb://localhost/ucome'
UCOME='druby://127.0.0.1:9007'

INTERVAL = 2
MAX_UPLOAD_SIZE  = 5000000

PREFIX = {'j' => '10', 'k' => '11', 'm' => '12', 'n' => '13',
          'o' => '14', 'p' => '15', 'q' => '16', 'r' => '17' }

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
  "q3"
end

# academic year. used by ucome only.
def a_year()
  now = Time.now
  if now.month < 4
    now.year-1
  else
    now.year
  end
end

def collection()
  "#{this_term()}_#{a_year()}"
end

def linux?()
  ENV['HOME'] =~ /^\/home/
end

def osx?()
  ENV['HOME'] =~ /^\/User/
end
