require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

#To make it gettext-compatible.
def _(str)
  return str
end

describe "Datet" do
  it "should have the same 'to_i' as normal time" do
    time = Time.now
    datet = Datet.new
    
    test_methods = [:year, :month, :day, :hour, :min, :sec, :to_i]
    test_methods.each do |method|
      tc = time.__send__(method)
      dc = datet.__send__(method)
      
      raise "Expected '#{method}'-calls to be the same but they werent: #{tc}  vs  #{dc}   (now: #{Time.now.__send__(method)})" if tc != dc
    end
  end
  
  it "should be able to make ago-strings" do
    time = Time.at(Time.now.to_i - 5)
    datet = Datet.in(time)
    res = datet.ago_str
    raise "Expected '5 seconds ago' but got: '#{res}'." if res != "5 seconds ago"
    
    
    time = Time.at(Time.now.to_i - 1800)
    datet = Datet.in(time)
    res = datet.ago_str
    raise "Expected '30 minutes ago' but got: '#{res}'." if res != "30 minutes ago"
    
    
    time = Time.at(Time.now.to_i - 60)
    datet = Datet.in(time)
    res = datet.ago_str
    raise "Expected '1 minute ago' but got: '#{res}'." if res != "1 minute ago"
    
    
    time = Time.at(Time.now.to_i - 48 * 3600)
    datet = Datet.in(time)
    res = datet.ago_str
    raise "Expected '2 days ago' but got: '#{res}'." if res != "2 days ago"
  end
  
  #From "knjrbfw_spec.rb".
  it "should be able to parse various date formats." do
    date = Datet.in("Wed, 13 Jul 2011 16:08:51 GMT").time
    date = Datet.in("2011-07-09 00:00:00 UTC").time
    date = Datet.in("1985-06-17 01:00:00").time
    date = Datet.in("1985-06-17").time
    date = Datet.in("17/06 1985").time
    date = Datet.in("2012-06-06").time
    
    raise "Couldnt register type 1 nullstamp." if !Datet.is_nullstamp?("0000-00-00")
    raise "Couldnt register type 2 nullstamp." if !Datet.is_nullstamp?("0000-00-00 00:00:00")
    raise "Registered nullstamp on valid date." if Datet.is_nullstamp?("1985-06-17")
    raise "Registered nullstamp on valid date." if Datet.is_nullstamp?("1985-06-17 10:30:00")
    
    date = Datet.in("2011-07-09 13:05:04 +0200")
    ltime = date.localtime_str
    
    #if RUBY_VERSION.slice(0, 3) == "1.9"
    #  if ltime != date.time.localtime
    #    raise "Calculated localtime (#{ltime}) was not the same as the real Time-localtime (#{date.time.localtime})."
    #  end
    #end
    
    if ltime != "2011-07-09 13:05:04 +0200"
      raise "Datet didnt return expected result: '#{ltime}'."
    end
  end
  
  it "should be able to compare dates" do
    date1 = Datet.in("17/06 1985")
    date2 = Datet.in("18/06 1985")
    date3 = Datet.in("17/06 1985")
    
    raise "Date1 was wrongly higher than date2." if date1 > date2
    
    if date2 > date1
      #do nothing.
    else
      raise "Date2 was wrongly not higher than date1."
    end
    
    raise "Date1 was wrongly not the same as date3." if date1 != date3
    raise "Date1 was the same as date2?" if date1 == date2
  end
  
  it "various methods should just work" do
    date = Datet.new(1985, 6, 17)
    raise "Invalid days in month: #{date.days_in_month}" if date.days_in_month != 30
  end
  
  it "should be able to handle invalid timestamps" do
    datet = Datet.new(2012, 7, 13, 16, 15, 04)
    raise "Expected dbstr to be '2012-07-13 16:15:04' but it wasnt: '#{datet.dbstr}'." if datet.dbstr != "2012-07-13 16:15:04"
    
    #Test 'add_secs'.
    datet.add_secs(120)
    raise "Expected dbstr to be '2012-07-13 16:17:04' but it wasnt: '#{datet.dbstr}'." if datet.dbstr != "2012-07-13 16:17:04"
    
    #Test 'add_days'.
    datet.add_days(60)
    raise "Expected dbstr to be '2012-09-11 16:17:04' but it wasnt: '#{datet.dbstr}'." if datet.dbstr != "2012-09-11 16:17:04"
    
    #Test 'add_usecs'.
    datet.add_usecs(10000000)
    raise "Expected dbstr to be '2012-09-11 16:17:14' but it wasnt: '#{datet.dbstr}'." if datet.dbstr != "2012-09-11 16:17:14"
    datet.add_usecs(-10000000)
    raise "Expected dbstr to be '2012-09-11 16:17:04' but it wasnt: '#{datet.dbstr}'." if datet.dbstr != "2012-09-11 16:17:04"
    
    #Test negative 'add_secs'.
    datet.add_secs(-125)
    raise "Expected dbstr to be '2012-09-11 16:14:59' but it wasnt: '#{datet.dbstr}'." if datet.dbstr != "2012-09-11 16:14:59"
    
    #Test negative 'add_days'.
    datet.add_days(-62)
    raise "Expected dbstr to be '2012-07-11 16:14:59' but it wasnt: '#{datet.dbstr}'." if datet.dbstr != "2012-07-11 16:14:59"
    
    #Test 'add_months'.
    datet.add_months(25)
    #raise "Expected dbstr to be '2014-08-11 16:14:59' but it wasnt: '#{datet.dbstr}'." if datet.dbstr != "2014-08-11 16:14:59"
    datet.add_months(-25)
    #raise "Expected dbstr to be '2012-07-11 16:14:59' but it wasnt: '#{datet.dbstr}'." if datet.dbstr != "2012-07-11 16:14:59"
    
    #Test 'add_years'.
    datet.add_years(12)
    raise "Expected dbstr to be '2024-07-11 16:14:59' but it wasnt: '#{datet.dbstr}'." if datet.dbstr != "2024-07-11 16:14:59"
    datet.add_years(-12)
    raise "Expected dbstr to be '2012-07-11 16:14:59' but it wasnt: '#{datet.dbstr}'." if datet.dbstr != "2012-07-11 16:14:59"
    
    #Test '0'-month-stuff.
    datet = Datet.new(2012, 9, 13, 18, 37, 20).add_months(15)
    raise "Expected dbstr to be '2013-12-13 18:37:20' but it wasnt: '#{datet.dbstr}'." if datet.dbstr != "2013-12-13 18:37:20"
    
    datet = Datet.new(2012, 3, 40)
    raise "Expected dbstr to be '2012-04-09' but it wasnt: '#{datet.dbstr(:time => false)}'." if datet.dbstr(:time => false) != "2012-04-09"
    
    datet = Datet.new(2012, 14)
    raise "Expected dbstr to be '2013-02-01' but it wasnt: '#{datet.dbstr(:time => false)}'." if datet.dbstr(:time => false) != "2013-02-01"
    
    datet = Datet.new(1985, 6, 17, 28)
    raise "Expected dbstr to be '1985-06-18 04:00:00' but it wasnt: '#{datet.dbstr}'." if datet.dbstr != "1985-06-18 04:00:00"
    
    datet = Datet.new(1985, 6, 17, 28, 68)
    raise "Expected dbstr to be '1985-06-18 05:08:00' but it wasnt: '#{datet.dbstr}'." if datet.dbstr != "1985-06-18 05:08:00"
    
    datet = Datet.new(1985, 6, 17, 28, 68, 68)
    raise "Expected dbstr to be '1985-06-18 05:09:09' but it wasnt: '#{datet.dbstr}'." if datet.dbstr != "1985-06-18 05:09:09"
    
    datet = Datet.new(1985, 6, 17, 28, 68, 68, 1000008)
    raise "Expected dbstr to be '1985-06-18 05:09:10' but it wasnt: '#{datet.dbstr}'." if datet.dbstr != "1985-06-18 05:09:10"
  end
  
  it "should be able to convert day-strings into numbers" do
    tests = {
      "mon" => 1,
      "tue" => 2,
      "wed" => 3,
      "thu" => 4,
      "fri" => 5,
      "sat" => 6,
      "sun" => 0,
      "monda" => 1,
      "tuesday" => 2,
      "wednes" => 3,
      "thursd" => 4,
      "frida" => 5,
      "satur" => 6,
      "sunday" => 0
    }
    
    tests.each do |test_str, right_res|
      res = Datet.day_str_to_no(test_str)
      raise "Expected result: '#{right_res}' but got: '#{res}'." if res != right_res
      
      #Check that the ':mfirst' is working as well (monday first day of week).
      res2 = Datet.day_str_to_no(test_str, :mfirst => true)
      if res == 0
        exp = 6
      else
        exp = res - 1
      end
      
      raise "Expected '#{exp}' but got: '#{res2}'." if res2 != exp
    end
  end
  
  it "should return the right leap years" do
    tests = {
      2006 => false,
      2007 => false,
      2008 => true,
      2009 => false,
      2010 => false,
      2011 => false,
      2012 => true,
      2013 => false
    }
    tests.each do |year, expected_res|
      res = Datet.gregorian_leap?(year)
      raise "Expected #{expected_res} but got #{res}" if res != expected_res
      
      days_in_year = Datet.days_in_year(year)
      if res
        exp = 366
      else
        exp = 365
      end
      
      raise "Expected #{exp} but got #{days_in_year}" if days_in_year != exp
    end
  end
  
  it "should be able to tell the amount of days between two dates" do
    tests = [
      {:d1 => Datet.new(2006, 1, 1), :d2 => Datet.new(2007, 1, 5), :days_exp => 369},
      {:d1 => Datet.new(2008, 1, 1), :d2 => Datet.new(2009, 1, 5), :days_exp => 370},
      {:d1 => Datet.new(2006, 1, 1), :d2 => Datet.new(2009, 1, 5), :days_exp => 1100},
      {:d1 => Datet.new(2000, 1, 1), :d2 => Datet.new(2010, 1, 5), :days_exp => 3657}
    ]
    tests.each do |data|
      days_betw = Datet.days_between(data[:d1], data[:d2])
      raise "Expected #{data[:days_exp]} but got #{days_betw}" if days_betw != data[:days_exp]
    end
  end
  
  it "should be able to calculate the correct week days" do
    tests = [
      [Datet.new(1905, 1, 1), 6],
      [Datet.new(1930, 1, 1), 2],
      [Datet.new(1940, 1, 1), 0],
      [Datet.new(1969, 12, 31), 2],
      [Datet.new(2012, 7, 15), 6],
      [Datet.new(2012, 7, 16), 0],
      [Datet.new(2012, 7, 17), 1]
    ]
    tests.each do |data|
      day_in_week = data[0].day_in_week(:mfirst => true)
      raise "Expected '#{data[1]}' but got '#{day_in_week}'." if day_in_week != data[1]
      
      diw = data[0].time.strftime("%w").to_i
      if diw == 0
        diw = 6
      else
        diw -= 1
      end
      
      raise "Time-method didnt return the same: #{diw}, #{day_in_week}" if diw != day_in_week
    end
  end
  
  it "should be compareable" do
    tests = [
      [Datet.new(2012, 6, 1, 14, 1, 1), Datet.new(2010, 6, 1, 14, 1, 1)],
      [Datet.new(2012, 6, 1, 14, 1, 1), Datet.new(2012, 5, 1, 14, 1, 1)],
      [Datet.new(2012, 6, 2, 14, 1, 1), Datet.new(2012, 6, 1, 14, 1, 1)],
      [Datet.new(2012, 6, 1, 14, 1, 1), Datet.new(2012, 6, 1, 13, 1, 1)]
    ]
    
    tests.each do |data|
      d1 = Datet.new(data[0])
      d2 = Datet.new(data[1])
      
      res_b = data[0] > data[1]
      res_s = data[0] < data[1]
      res_e = data[0] == data[1]
      
      raise "Expected 'res_bigger' to be true but it wasnt: #{res_b}" if res_b != true
      raise "Expected 'res_smaller' to be false but it wasnt: #{res_s}" if res_s != false
      raise "Expected 'res_equal' to be false but it wasnt: #{res_e}" if res_e != false
    end
  end
  
  it "should be able to return day-strings" do
    datet = Datet.new(1970, 1, 4)
    6.times do |i|
      day_str = datet.day_str
      exp = Datet.days[i]
      raise "Expected '#{exp}' but got '#{day_str}' for day-no: '#{i}'." if day_str != exp
      datet.days + 1
    end
    
    #Check date 'mfirst' works (monday first day of week).
    days_str_sf = Datet.days
    days_str_mf = Datet.days(:mfirst => true)
    
    days_str_mf.each do |key, val|
      if key == 6
        use_key = 0
      else
        use_key = key + 1
      end
      
      res = days_str_sf[use_key]
      raise "Expected '#{val}' but got: '#{res}' for key: '#{use_key}'." if res != val
    end
  end
  
  it "should be able to calculate the day of the year" do
    tests = [
      [Datet.new(2005, 1, 1), 1],
      [Datet.new(2005, 12, 31), 365],
      [Datet.new(2005, 3, 1), 60],
      [Datet.new(2008, 3, 1), 61],
      [Datet.new(2005, 2, 27), 58],
      [Datet.new(2008, 2, 27), 58]
    ]
    
    tests.each do |data|
      res = data[0].day_of_year
      raise "Expected '#{data[1]}' but got: '#{res}' for #{data[0]}." if res != data[1]
    end
  end
  
  it "should return http-dates" do
    tests = [
      [Datet.new(1985, 6, 17, 8), "Mon, 17 Jun 1985 08:00:00 GMT"]
    ]
    
    tests.each do |data|
      res = data[0].httpdate
      raise "Expected: '#{data[1]}' but got: '#{res}'." if res != data[1]
    end
  end
  
  it "should be able to do finds" do
    #This is a monday.
    datet = Datet.new(1970, 1, 4)
    
    datet.find(:incr => :day, :wday => 4)
    raise "Expected 'day_name' to be 'Thursday' but it wasnt: '#{datet.day_name}'." if datet.day_name != "Thursday"
    
    datet.find(:incr => :month, :wday => 5)
    raise "Expected dbstr to be '1970-05-08' but it wasnt: '#{datet.dbstr(:time => false)}'." if datet.dbstr(:time => false) != "1970-05-08"
  end
  
  it "should be able to calculate week numbers" do
    tests = [
      [Datet.new(1985, 1, 1), 1],
      [Datet.new(1985, 12, 31), 53]
    ]
    tests.each do |data|
      res = data[0].week_no
      raise "Expected '#{data[1]}' but got '#{res}'." if res != data[1]
    end
  end
  
  it "should emulate strftime" do
    datet = Datet.new(1985, 6, 17, 10, 30, 25)
    
    tests = {
      "%Y" => 1985,
      "%m" => "06",
      "%d" => "17",
      "%e" => 17,
      "%H" => 10,
      "%l" => 10,
      "%I" => 10,
      "%k" => 10,
      "%M" => 30,
      "%S" => 25,
      "%T" => "10:30:25",
      "%R" => "10:30",
      "%r" => "10:30:25 AM",
      "%p" => "am",
      "%P" => "AM",
      "%B" => "June",
      "%^B" => "JUNE",
      "%b" => "Jun",
      "%h" => "Jun",
      "%^b" => "JUN",
      "%j" => 168,
      "%A" => "Monday",
      "%^A" => "MONDAY",
      "%a" => "Mon",
      "%^a" => "MON",
      "%w" => 1,
      "%s" => datet.to_i,
      "%P" => "am",
      "%p" => "AM",
      "%V" => 25,
      "%W" => 24,
      "%%Y" => "%Y",
      "%%%%%Y" => "%%1985",
      "%%%%%%%%%Y" => "%%%%1985"
    }
    
    tests.each do |key, val|
      res = datet.strftime(key)
      raise "Expected '#{val}' but got: '#{res}' for '#{key}'." if val.to_s != res
      
      res2 = datet.time.strftime(key)
      raise "Expected res to be the same as time res but it wasnt: '#{res}', '#{res2}' for '#{key}'." if res != res2
    end
  end
  
  it "should handle nil-dates gently" do
    datet = Datet.new(0, 0, 0)
    
    tests = [
      [:dbstr, "0000-00-00 00:00:00"]
    ]
    tests.each do |data|
      res = datet.__send__(data[0])
      raise "Expected '#{data[1]}' but got '#{res}'." if res != data[1]
    end
  end
  
  it "should not be possible to set invalid months and dates" do
    datet = Datet.new
    
    begin
      datet.month = 14
      raise "Should have raised error."
    rescue ArgumentError
      #ignore
    end
    
    begin
      datet.usec = 1000005
      raise "Should have raised error."
    rescue ArgumentError
      #ignore.
    end
    
    begin
      datet.sec = 61
      raise "Should have raised error."
    rescue ArgumentError
      #ignore
    end
    
    begin
      datet.min = 70
      raise "Should have raised error."
    rescue ArgumentError
      #ignore.
    end
    
    begin
      datet.hour = 90
      raise "Should have raised error."
    rescue ArgumentError
      #ignore.
    end
    
    begin
      datet.day = 45
      raise "Should have raised error."
    rescue ArgumentError
      #ignore.
    end
  end
  
  it "should be able to set seconds lazy" do
    datet = Datet.new(1985, 6, 17, 10)
    datet.lazy_sec = 125
    raise "Expected time to be '1985-06-17 10:02:05' but it was: '#{datet.dbstr}'." if datet.dbstr != "1985-06-17 10:02:05"
  end
  
  it "should be able to set minutes lazy" do
    datet = Datet.new(1985, 6, 17, 10)
    datet.lazy_min = 125
    raise "Expected time to be '1985-06-17 12:05:00' but it was: '#{datet.dbstr}'." if datet.dbstr != "1985-06-17 12:05:00"
    
    datet.lazy_min = 30.5
    raise "Expected time to be '1985-06-17 12:30:30' but it was: '#{datet.dbstr}'." if datet.dbstr != "1985-06-17 12:30:30"
  end
  
  it "should be able to set hours lazy" do
    datet = Datet.new(1985, 6, 17, 10)
    datet.lazy_hour = 28.5
    raise "Expected time to be '1985-06-18 04:30:00' but it was: '#{datet.dbstr}'." if datet.dbstr != "1985-06-18 04:30:00"
  end
end