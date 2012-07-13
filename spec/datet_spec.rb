require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

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
    end
  end
end