APP_NAME="icome8"
VERSION="0.2.1"
UPDATE="2016-09-06"


# academic year
def a_year()
  now = Time.now
  if now.month < 4
    now.year-1
  else
    now.year
  end
end

def this_term()
  "q3"
end
