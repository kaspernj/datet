#This class handels various time- and date-specific behaviour in a friendly way.
#===Examples
# datet = Datet.new #=> 2012-05-03 20:35:16 +0200
# datet = Datet.new(Time.now) #=> 2012-05-03 20:35:16 +0200
# datet.months + 5 #=> 2012-10-03 20:35:16 +0200
# datet.days + 64 #=> 2012-12-06 20:35:16 +010
class Datet
  @@months_lcase = {
    "jan" => 1,
    "january" => 1,
    "feb" => 2,
    "february" => 2,
    "mar" => 3,
    "march" => 3,
    "apr" => 4,
    "april" => 4,
    "may" => 5,
    "jun" => 6,
    "june" => 6,
    "jul" => 7,
    "july" => 7,
    "aug" => 8,
    "august" => 8,
    "sep" => 9,
    "september" => 9,
    "oct" => 10,
    "october" => 11,
    "nov" => 11,
    "november" => 11,
    "dec" => 12,
    "december" => 12
  }
  
  @@days_lcase = {
    "sunday" => 0,
    "monday" => 1,
    "tuesday" => 2,
    "wednesday" => 3,
    "thursday" => 4,
    "friday" => 5,
    "saturday" => 6
  }
  @@days_lcase.clone.each do |key, val|
    @@days_lcase[key[0, 3]] = val
  end
  
  @@day_names = {
    0 => "Sunday",
    1 => "Monday",
    2 => "Tuesday",
    3 => "Wednesday",
    4 => "Thursday",
    5 => "Friday",
    6 => "Saturday"
  }
  
  @@month_names = {
    1 => "January",
    2 => "February",
    3 => "March",
    4 => "April",
    5 => "May",
    6 => "June",
    7 => "July",
    8 => "August",
    9 => "September",
    10 => "October",
    11 => "November",
    12 => "December"
  }
  
  #Thanks to ActiveSupport: http://rubydoc.info/docs/rails/2.3.8/ActiveSupport/CoreExtensions/Time/Calculations
  @@days_in_months = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  
  #Initializes the object. Default is the current time. A time-object can be given.
  #=Examples
  # datet = Datet.new #=> Datet-object with the current date and time.
  # 
  # time = Time.new
  # datet = Datet.new(time) #=> Datet-object with the date and time from the given Time-object.
  # 
  # datet = Datet.new(1985, 06, 17) #=> Datet-object with the date 1985-06-17.
  # datet = Datet.new(1985, 06, 17, 10) #=> Datet-object with the date 1985-06-17 10:00:00
  # 
  # datet = Datet.new(1985, 06, 35) #=> Datet-object with the date 1985-07-05 00:00:00. Notice the invalid day of 35 was automatically converted to the right date.
  def initialize(*args)
    if args.length == 1 and args.first.is_a?(Time)
      self.update_from_time(args.first)
      return nil
    elsif args.empty?
      self.update_from_time(Time.now)
      return nil
    end
    
    #Handle nil-support.
    all_nil = true
    args.each do |arg|
      if arg != 0 and arg
        all_nil = false
        break
      end
    end
    
    if all_nil
      @t_nil = true
      @t_year = 0
      @t_month = 0
      @t_day = 0
      @t_hour = 0
      @t_min = 0
      @t_sec = 0
      @t_usec = 0
      return nil
    end
    
    
    #Normal date-calculation support.
    days_left = 0
    months_left = 0
    hours_left = 0
    mins_left = 0
    secs_left = 0
    usecs_left = 0
    
    #Check larger month the allowed.
    if args[1] and args[1] > 12
      months_left = args[1] - 12
      args[1] = 12
    end
    
    #Check larger date than allowed.
    if args[1]
      dim = Datet.days_in_month(args[0], args[1])
      if args[2] and args[2] > dim
        days_left = args[2] - dim
        args[2] = dim if days_left > 0
      end
    end
    
    #Check larger hour than allowed.
    if args[3] and args[3] >= 24
      hours_left = args[3] + 1
      args[3] = 0
    end
    
    #Check larger minute than allowed.
    if args[4] and args[4] >= 60
      mins_left = args[4] + 1
      args[4] = 0
    end
    
    #Check larger secs than allowed.
    if args[5] and args[5] >= 60
      secs_left = args[5] + 1
      args[5] = 0
    end
    
    #Check larger usecs than allowed.
    if args[6] and args[6] >= 1000000
      usecs_left = args[6] + 1
      args[6] = 0
    end
    
    #Generate new stamp.
    if args[0]
      @t_year = args[0]
    else
      @t_year = Time.now.year
    end
    
    if args[1]
      @t_month = args[1]
    else
      @t_month = 1
    end
    
    if args[2]
      @t_day = args[2]
    else
      @t_day = 1
    end
    
    if args[3]
      @t_hour = args[3]
    else
      @t_hour = 0
    end
    
    if args[4]
      @t_min = args[4]
    else
      @t_min = 0
    end
    
    if args[5]
      @t_sec = args[5]
    else
      @t_sec = 0
    end
    
    if args[6]
      @t_usec = args[6]
    else
      @t_usec = 0
    end
    
    self.add_mins(mins_left) if mins_left > 0
    self.add_hours(hours_left) if hours_left > 0
    self.add_days(days_left) if days_left > 0
    self.add_months(months_left) if months_left > 0
    self.add_secs(secs_left) if secs_left > 0
    self.add_usecs(usecs_left) if usecs_left > 0
  end
  
  #Updates the current variables to the given time.
  #===Examples
  # datet.update_from_time(Time.now)
  def update_from_time(time)
    @t_year = time.year
    @t_month = time.month
    @t_day = time.day
    @t_hour = time.hour
    @t_min = time.min
    @t_sec = time.sec
    @t_usec = time.usec
    
    nil
  end
  
  #Returns a new 'Time'-object based on the data of the 'Datet'-object.
  #=Examples
  # Datet.new.time #=> 2012-07-13 16:14:27 +0200
  def time
    return Time.new(@t_year, @t_month, @t_day, @t_hour, @t_min, @t_sec)
  end
  
  #Goes forward day-by-day and stops at a date matching the criteria given.
  #
  #===Examples
  # datet.time #=> 2012-05-03 19:36:08 +0200
  #
  #Try to find next saturday.
  # datet.find(:day, :day_in_week => 5) #=> 2012-05-05 19:36:08 +0200
  #
  #Try to find next wednesday by Time's wday-method.
  # datet.find(:day, :wday => 3) #=> 2012-05-09 19:36:08 +0200
  def find(args)
    #Test arguments.
    raise ArgumentError, "Too little arguments given: #{args.length}" if args.length < 2
    
    args.each do |key, val|
      case key
        when :wday_mfirst, :wday, :incr
        else
          raise ArgumentError, "Invalid key in arguments: '#{key}'."
      end
    end
    
    #Find the date.
    count = 0
    while true
      if args[:wday_mfirst] and self.day_in_week(:mfirst => true) == args[:wday_mfirst]
        return self
      elsif args[:wday] and self.day_in_week == args[:wday]
        return self
      end
      
      if args[:incr] == :day
        self.add_days(1)
      elsif args[:incr] == :month
        self.add_months(1)
      else
        raise ArgumentError, "Invalid increment: #{incr}."
      end
      
      count += 1
      raise "Endless loop?" if count > 999
    end
  end
  
  #Add a given amount of micro-seconds to the object.
  def add_usecs(usecs = 1)
    usecs = usecs.to_i
    cur_usecs = @t_usec
    next_usec  = cur_usecs + usecs
    
    if next_usec >= 1000000 or next_usec <= -1000000
      secs = (next_usec.to_f / 1000000.0).to_f.floor
      @t_usec = next_usec - (secs * 1000000)
      self.add_secs(secs)
    else
      @t_usec = next_usec
    end
    
    return self
  end
  
  #Add a given amount of seconds to the object.
  def add_secs(secs = 1)
    secs = secs.to_i
    cur_secs = @t_sec
    next_sec = cur_secs + secs
    
    if next_sec >= 60 or next_sec <= -60
      mins = (next_sec.to_f / 60.0).floor
      @t_sec = next_sec - (mins * 60)
      self.add_mins(mins)
    else
      @t_sec = next_sec
    end
    
    return self
  end
  
  #Add a given amount of minutes to the object.
  #===Examples
  # datet = Datet.new #=> 2012-05-03 17:39:45 +0200
  # datet.add_mins(30)
  # datet.time #=> 2012-05-03 18:08:45 +0200
  def add_mins(mins = 1)
    mins = mins.to_i
    cur_mins = @t_min
    next_min  = cur_mins + mins
    
    if next_min >= 60
      @t_min = 0
      self.add_hours(1)
      mins_left = (mins - 1) - (60 - cur_mins)
      self.add_mins(mins_left) if mins_left > 0
    elsif next_min < 0
      @t_min = 59
      self.add_hours(-1)
      mins_left = mins + cur_mins + 1
      self.add_mins(mins_left) if mins_left > 0
    else
      @t_min = next_min
    end
    
    return self
  end
  
  #Adds a given amount of hours to the object.
  #===Examples
  # datet = Datet.new
  # datet.add_hours(2)
  def add_hours(hours = 1)
    hours = hours.to_i
    cur_hour = @t_hour
    next_hour = cur_hour + hours
    
    if next_hour >= 24
      @t_hour = 0
      self.add_days(1)
      hours_left = (hours - 1) - (24 - cur_hour)
      self.add_hours(hours_left) if hours_left > 0
    elsif next_hour < 0
      @t_hour = 23
      self.add_days(-1)
      hours_left = hours + cur_hour + 1
      self.add_hours(hours_left) if hours_left < 0
    else
      @t_hour = next_hour
    end
    
    return self
  end
  
  #Adds a given amount of days to the object.
  #===Examples
  # datet = Datet.new #=> 2012-05-03 17:42:27 +0200
  # datet.add_days(29)
  # datet.time #=> 2012-06-01 17:42:27 +0200
  def add_days(days = 1)
    days = days.to_i
    dim = self.days_in_month
    cur_day = @t_day
    next_day = cur_day + days
    
    if next_day > dim
      @t_day = 1
      self.add_months(1)
      days_left = (days - 1) - (dim - cur_day)
      self.add_days(days_left) if days_left != 0
    elsif next_day < 0
      self.add_months(-1)
      @t_day = self.days_in_month
      days_left = days + cur_day
      self.add_days(days_left) if days_left != 0
    else
      @t_day = next_day
    end
    
    return self
  end
  
  #Adds a given amount of months to the object.
  #===Examples
  # datet.time #=> 2012-06-01 17:42:27 +0200
  # datet.add_months(2)
  # datet.time #=> 2012-08-01 17:42:27 +0200
  def add_months(months = 1)
    months = months.to_i
    cur_month = @t_month
    cur_day = @t_day
    next_month = cur_month + months.to_i
    
    #Check if we have to alter the amount of years based on the month-change.
    if next_month > 12 or next_month < 0
      years = (next_month.to_f / 12.0).floor
      
      newmonth = next_month - (years * 12)
      if newmonth == 0
        newmonth = 12
        years -= 1
      end
      
      self.month = newmonth
      self.add_years(years) if years != 0
    else
      @t_month = next_month
      @t_day = 1
    end
    
    
    #If the month changed, and the day was the last day of the previous month, and there isnt that many days in the new month, set the day to the last day of the current month.
    dim = self.days_in_month
    
    if dim < cur_day
      @t_day = dim
    else
      @t_day = cur_day
    end
    
    return self
  end
  
  #Adds a given amount of years to the object.
  #===Examples
  # datet.time #=> 2012-08-01 17:42:27 +0200
  # datet.add_years(3)
  # datet.time #> 2014-08-01 17:42:27 +0200
  def add_years(years = 1)
    @t_year = @t_year + years.to_i
    return self
  end
  
  #Is a year a leap year in the Gregorian calendar? Copied from Date-class.
  #===Examples
  # if Datet.gregorian_leap?(2005)
  #   print "2005 is a gregorian-leap year."
  # else
  #   print "2005 is not a gregorian-leap year."
  # end
  def self.gregorian_leap?(y)
    if y % 4 == 0 && y % 100 != 0
      return true
    elsif y % 400 == 0
      return true
    else
      return false
    end
  end
  
  #Returns the number of days in the month.
  #===Examples
  # datet = Datet.new
  # print "There are #{datet.days_in_month} days in the current month."
  def days_in_month
    return Datet.days_in_month(@t_year, @t_month)
  end
  
  #Class-method for days in month.
  def self.days_in_month(year, month)
    raise ArgumentError, "Invalid month: '#{month}'." if month.to_i <= 0
    return 29 if month == 2 and Datet.gregorian_leap?(year)
    return @@days_in_months[month]
  end
  
  #Returns the amount of days in the current year.
  def days_in_year
    return Datet.days_in_year(@t_year)
  end
  
  #Returns the amount of days in the given year.
  def self.days_in_year(year)
    return 366 if Datet.gregorian_leap?(year)
    return 365
  end
  
  #Returns the day in the week.
  #===Examples
  #Get a monday:
  # datet = Datet.new(1970, 1, 4)
  # datet.day_in_week #=> 1
  # datet.day_in_week(:mfirst = true) #=> 0
  def day_in_week(args = nil)
    if args
      args.each do |key, val|
        case key
          when :mfirst
          else
            raise ArgumentError, "Invalid key in arguments: '#{key}'."
        end
      end
    end
    
    #This is a monday - 0. Use this date to calculate up against.
    def_date = Datet.new(1970, 1, 4)
    
    if self > def_date
      days = Datet.days_between(def_date, self)
      factor = days.to_f / 7.0
      diw = days - (factor.floor * 7)
    else
      days = Datet.days_between(self, def_date)
      factor = days.to_f / 7.0
      diw = days - (factor.floor * 7)
      diw = 7 - diw
      diw = 0 if diw == 7
    end
    
    #Monday should be the first day in the week.
    if args and args[:mfirst]
      if diw == 0
        diw = 6
      else
        diw -= 1
      end
    end
    
    return diw
  end
  
  #Returns the week-number of the year (1..53).
  def week_no(args = nil)
    week_no = (self.day_of_year.to_f / 7).to_i + 1
    
    if args and args[:mfirst] and self.day_in_week == 1
      week_no -= 1
    end
    
    return week_no
  end
  
  #Returns the days name as a string.
  def day_name
    return @@day_names[self.day_in_week]
  end
  
  #Returns the day as a localized string.
  #===Examples
  # Datet.new.day_str #=> "Monday"
  # Datet.new.day_str(:short => true) #=> "Mon"
  def day_str(args = nil)
    ret = Datet.days(:trans => true)[self.day_in_week]
    if args and args[:short]
      ret = ret.slice(0, 3)
    end
    
    return ret
  end
  
  #Returns the month as a localized string.
  #===Examples
  # Datet.new.month_str #=> "January"
  def month_str
    ret = Datet.months(:trans => true)[@t_month]
    if args and args[:short]
      ret = ret.slice(0, 3)
    end
    
    return ret
  end
  
  #Returns the months name as a string.
  def month_name
    return @@month_names[@t_month]
  end
  
  #Returns the year as an integer.
  def year
    return @t_year
  end
  
  #Returns the hour as an integer.
  def hour
    return @t_hour
  end
  
  #Returns the hour as an integer in the twelve-hour-clock.
  def hour_thc
    hour = @t_hour
    hour -= 12 if hour > 12
    return hour
  end
  
  #Returns the minute as an integer.
  def min
    return @t_min
  end
  
  #Returns the seconds as an integer.
  def sec
    return @t_sec
  end
  
  #Returns the microsecond as an integer.
  def usec
    return @t_usec
  end
  
  #Returns "am" or "pm" based on the hours values.
  def ampm
    if @t_hour <= 12
      return "am"
    else
      return "pm"
    end
  end
  
  #Changes the year to the given year.
  # datet = Datet.now #=> 2014-05-03 17:46:11 +0200
  # datet.year = 2005
  # datet.time #=> 2005-05-03 17:46:11 +0200
  def year=(newyear)
    @t_year = newyear.to_i
  end
  
  #Returns the month as an integer.
  def month
    Thread.current[:datet_mode] = :months
    return @t_month
  end
  
  #Returns the day in month as an integer.
  def date
    Thread.current[:datet_mode] = :days
    return @t_day
  end
  
  #Changes the date to a given date.
  #===Examples
  # datet.time #=> 2005-05-03 17:46:11 +0200
  # datet.date = 8
  # datet.time #=> 2005-05-08 17:46:11 +0200
  def date=(newday)
    newday = newday.to_i
    
    if newday <= 0
      self.add_days(newday - 1)
    else
      @t_day = newday
    end
    
    return self
  end
  
  #Changes the hour to a given new hour.
  #===Examples
  # datet.time #=> 2012-05-09 19:36:08 +0200
  # datet.hour = 5
  # datet.time #=> 2012-05-09 05:36:08 +0200
  def hour=(newhour)
    newhour = newhour.to_i
    day = @t_day
    
    loop do
      break if newhour >= 0
      day += -1
      newhour += 24
    end
    
    loop do
      break if newhour < 24
      day += 1
      newhour += -24
    end
    
    @t_hour = newhour
    
    self.date = day if day != @t_day
    return self
  end
  
  #Changes the minute to a given new minute.
  #===Examples
  # datet.time #=> 2012-05-09 05:36:08 +0200
  # datet.min = 35
  # datet.time #=> 2012-05-09 05:35:08 +0200
  def min=(newmin)
    @t_min = newmin.to_i
  end
  
  #Changes the second to a given new second.
  #===Examples
  # datet.time #=> 2012-05-09 05:35:08 +0200
  # datet.sec = 20
  # datet.time #=> 2012-05-09 05:35:20 +0200
  def sec=(newsec)
    @t_sec = newsec.to_i
  end
  
  alias :day :date
  
  #Changes the month to a given new month.
  #===Examples
  # datet.time #=> 2012-05-09 05:35:20 +0200
  # datet.month = 7
  # datet.time #=> 2012-07-09 05:35:20 +0200
  def month=(newmonth)
    newmonth = newmonth.to_i
    raise ArgumentError, "Invalid month: '#{newmonth}'." if newmonth <= 0
    @t_month = newmonth
  end
  
  #Turns the given argument into a new Time-object.
  #===Examples
  # time = Datet.arg_to_time(datet) #=> <Time>-object
  # time = Datet.arg_to_time(Time.now) #=> <Time>-object
  def self.arg_to_time(datet)
    if datet.is_a?(Datet)
      return datet.time
    elsif datet.is_a?(Time)
      return datet
    else
      raise ArgumentError, "Could not handle object of class: '#{datet.class.name}'."
    end
  end
  
  #Turns the given argument into a new Datet-object. Helps compare datet- to time-objects.
  #===Examples
  # time = Datet.arg_to_time(datet) #=> <Datet>-object
  # time = Datet.arg_to_time(Datet.now) #=> <Datet>-object
  def self.arg_to_datet(datet)
    if datet.is_a?(Datet)
      return datet
    elsif datet.is_a?(Time)
      return Datet.new(datet)
    else
      raise ArgumentError, "Could not handle object of class: '#{datet.class.name}'."
    end
  end
  
  #Make the class compareable. Also to time-objects.
  include Comparable
  def <=>(timeobj)
    timeobj = Datet.arg_to_datet(timeobj)
    
    tries = [:year, :month, :day, :hour, :min, :sec, :usec]
    tries.each do |try|
      res1 = timeobj.__send__(try)
      res2 = self.__send__(try)
      
      if res1 > res2
        return -1
      elsif res1 < res2
        return 1
      end
    end
    
    return 0
  end
  
  #This method is used for adding values to the object based on the current set mode.
  #===Examples
  #Add two months to the datet.
  # datet.months
  # datet.add_something(2)
  def add_something(val)
    val = -val if Thread.current[:datet_addmode] == "-"
    return self.add_years(val) if Thread.current[:datet_mode] == :years
    return self.add_hours(val) if Thread.current[:datet_mode] == :hours
    return self.add_days(val) if Thread.current[:datet_mode] == :days
    return self.add_months(val) if Thread.current[:datet_mode] == :months
    return self.add_mins(val) if Thread.current[:datet_mode] == :mins
    return self.add_secs(val) if Thread.current[:datet_mode] == :secs
    return self.add_usecs(val) if Thread.current[:datet_mode] == :usecs
    raise "No such mode: '#{Thread.current[:datet_mode]}'."
  end
  
  #Minus something.
  #===Examples
  # datet.months - 5
  # datet.years - 2
  def -(val)
    Thread.current[:datet_addmode] = "-"
    self.add_something(val)
  end
  
  #Add something.
  #===Examples
  # datet.months + 5
  # datet.months + 2
  def +(val)
    Thread.current[:datet_addmode] = "+"
    self.add_something(val)
  end
  
  #Sets the mode to hours and gets ready to plus or minus.
  #===Examples
  # datet.time #=> 2005-05-08 17:46:11 +0200
  # datet.hours + 5
  # datet.time #=> 2005-05-08 22:46:11 +0200
  def hours
    Thread.current[:datet_mode] = :hours
    return self
  end
  
  #Sets the mode to minutes and gets ready to plus or minus.
  #===Examples
  # datet.time #=> 2005-05-08 22:46:11 +0200
  # datet.mins + 5
  # datet.mins #=> 2005-05-08 22:51:11 +0200
  def mins
    Thread.current[:datet_mode] = :mins
    return self
  end
  
  #Sets the mode to seconds and gets ready to plus or minus.
  def secs
    Thread.current[:datet_mode] = :secs
    return self
  end
  
  #Sets the mode to mili-seconds and gets ready to plus or minus.
  def usecs
    Thread.current[:datet_mode] = :usecs
    return self
  end
  
  #Sets the mode to days and gets ready to plus or minus.
  #===Examples
  # datet.time #=> 2005-05-08 22:51:11 +0200
  # datet.days + 26
  # datet.time #=> 2005-06-03 22:51:11 +0200
  def days
    Thread.current[:datet_mode] = :days
    return self
  end
  
  #Sets the mode to months and gets ready to plus or minus.
  #===Examples
  # datet.time #=> 2005-06-03 22:51:11 +0200
  # datet.months + 14
  # datet.time #=> 2006-08-01 22:51:11 +0200
  def months
    Thread.current[:datet_mode] = :months
    return self
  end
  
  #Sets the mode to years and gets ready to plus or minus.
  #===Examples
  # datet.time #=> 2006-08-01 22:51:11 +0200
  # datet.years + 5
  # datet.time #=> 2011-08-01 22:51:11 +0200
  def years
    Thread.current[:datet_mode] = :years
    return self
  end
  
  #Returns a new Datet- or Time-object based on the arguments.
  #===Examples
  # time = datet.stamp(:datet => false, :min => 15, :day => 5) #=> 2012-07-05 05:15:20 +0200
  def stamp(args)
    vars = {:year => @t_year, :month => @t_month, :day => @t_day, :hour => @t_hour, :min => @t_min, :sec => @t_sec, :usec => @t_usec}
    
    args.each do |key, value|
      vars[key.to_sym] = value.to_i if key != :datet
    end
    
    time = Time.local(vars[:year], vars[:month], vars[:day], vars[:hour], vars[:min], vars[:sec], vars[:usec])
    
    if !args.key?(:datet) or args[:datet]
      return Datet.new(time)
    end
    
    return time
  end
  
  #Returns the time as a database-valid string.
  #===Examples
  # datet.time #=> 2011-08-01 22:51:11 +0200
  # datet.dbstr #=> "2011-08-01 22:51:11"
  # datet.dbstr(:time => false) #=> "2011-08-01"
  def dbstr(args = nil)
    str = "#{"%04d" % @t_year}-#{"%02d" % @t_month}-#{"%02d" % @t_day}"
    
    if !args or (!args.key?(:time) or args[:time])
      str << " #{"%02d" % @t_hour}:#{"%02d" % @t_min}:#{"%02d" % @t_sec}"
    end
    
    return str
  end
  
  #Returns true of the given stamp is a 'nullstamp'.
  #===Examples
  # Datet.is_nullstamp?("0000-00-00") #=> true
  # Datet.is_nullstamp?("0000-00-00 00:00:00") #=> true
  # Datet.is_nullstamp?("") #=> true
  # Datet.is_nullstamp?("1985-06-17") #=> false
  def self.is_nullstamp?(stamp)
    return true if !stamp or stamp == "0000-00-00" or stamp == "0000-00-00 00:00:00" or stamp.to_s.strip == ""
    return false
  end
  
  #Returns true if this date is a nullstamp (0000-00-00 or something like it).
  def nullstamp?
    return true if @t_nil
    return false
  end
  
  #Returns the day of the year (0-365) as an integer.
  #===Examples
  # Datet.new.day_of_year #=> 123
  def day_of_year
    count = @t_day
    @@days_in_months.each_index do |key|
      break if key >= @t_month
      val = @@days_in_months[key]
      
      if key == 2 and Datet.gregorian_leap?(@t_year)
        count += 29
      else
        count += val.to_i
      end
    end
    
    return count
  end
  
  #Returns how many days there is between the two timestamps given as an integer.
  #===Examples
  # d1 = Datet.new #=> 2012-05-03 18:04:12 +0200
  # d2 = Datet.new #=> 2012-05-03 18:04:16 +0200
  # d2.months + 5 #=> 2012-10-03 18:04:16 +0200
  # Datet.days_between(d1, d2) #=> 153
  def self.days_between(t1, t2)
    raise ArgumentError, "Timestamp 2 should be larger than timestamp 1." if t2 < t1
    
    doy1 = t1.day_of_year
    doy2 = t2.day_of_year
    
    yot1 = t1.year
    yot2 = t2.year
    
    days = 0
    
    #If there is a years-difference, then neutralize the first year by counting up to next year and starting from 1/1.
    if yot1 < yot2
      diy = Datet.days_in_year(yot1)
      days += diy - doy1 + 1
      doy1 = 1
      yot1 += 1
    end
    
    #For each year calculate the amount of days in that year and add them to the count.
    while yot1 < yot2
      diy = Datet.days_in_year(yot1)
      days += diy
      yot1 += 1
    end
    
    #Last calculate the difference between the two dates and add the count to that.
    days_between = doy2 - doy1
    return days_between + days
  end
  
  #Returns a string based on the date and time.
  #===Examples
  # datet.out #=> "03/05 2012 - 18:04"
  # datet.out(:time => false) #=> "03/05 2012"
  # datet.out(:date => false) #=> "18:04"
  def out(args = {})
    str = ""
    date_shown = false
    time_shown = false
    
    if !args.key?(:date) or args[:date]
      date_shown = true
      str << "#{"%02d" % @t_day}/#{"%02d" % @t_month}"
      
      if !args.key?(:year) or args[:year]
        str << " #{"%04d" % @t_year}"
      end
    end
    
    if !args.key?(:time) or args[:time]
      show_time = true
      
      if args.key?(:zerotime) and !args[:zerotime]
        if @t_hour == 0 and @t_min == 0
          show_time = false
        end
      end
      
      if show_time
        time_shown = true
        str << " - " if date_shown
        str << "#{"%02d" % @t_hour}:#{"%02d" % @t_min}"
      end
    end
    
    return str
  end
  
  #Parses various objects into Datet-objects.
  #===Examples
  # datet = Datet.in("1985-06-17") #=> 1985-06-17 00:00:00 +0200
  # datet = Datet.in("1985-06-17 10:00:00") #=> 1985-06-17 10:00:00 +0200
  # datet = Datet.in("17/06 1985 10:00") #=> 1985-06-17 10:00:00 +0200
  def self.in(timestr)
    if timestr.is_a?(Time)
      return Datet.new(timestr)
    elsif timestr.is_a?(Date)
      return Datet.new(timestr.to_time)
    elsif timestr.is_a?(Datet)
      return timestr
    elsif Datet.is_nullstamp?(timestr)
      return false
    end
    
    timestr_t = timestr.to_s.downcase.strip
    
    if match = timestr_t.match(/^(\d+)\/(\d+) (\d+)/)
      #MySQL date format
      timestr = timestr.gsub(match[0], "")
      date = match[1].to_i
      month = match[2].to_i
      year = match[3].to_i
      
      if match = timestr.match(/\s*(\d+):(\d+)/)
        #MySQL datetime format
        hour = match[1].to_i
        minute = match[2].to_i
      end
      
      return Datet.new(year, month, date, hour, minute)
    elsif match = timestr_t.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/)
      return Datet.new(match[3], match[2], match[1])
    elsif match = timestr_t.match(/^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})(\d{5,6})$/)
      #Datet.code format
      return Datet.new(match[1], match[2], match[3], match[4], match[5], match[6], match[7])
    elsif match = timestr_t.match(/^\s*(\d{4})-(\d{1,2})-(\d{1,2})(|\s+(\d{2}):(\d{2}):(\d{2})(|\.\d+)\s*)(|\s+(utc))(|\s+(\+|\-)(\d{2})(\d{2}))$/)
      #Database date format (with possibility of .0 in the end - microseconds? -knj.
      
      if match[11] and match[13] and match[14]
        if match[12] == "+" or match[12] == "-"
          sign = match[12]
        else
          sign = "+"
        end
        
        utc_str = "#{sign}#{match[13]}:#{match[14]}"
      elsif match[8]
        utc_str = match[8].to_i
      else
        utc_str = nil
      end
      
      if utc_str
        time = Time.local(match[1].to_i, match[2].to_i, match[3].to_i, match[5].to_i, match[6].to_i, match[7].to_i, utc_str)
        return Datet.new(time)
      else
        return Datet.new(match[1].to_i, match[2].to_i, match[3].to_i, match[5].to_i, match[6].to_i, match[7].to_i)
      end
    elsif match = timestr_t.match(/^\s*(\d{2,4})-(\d{1,2})-(\d{1,2})(|\s+(\d{1,2}):(\d{1,2}):(\d{1,2})(:(\d{1,2})|)\s*)$/)
      return Datet.new(match[1].to_i, match[2].to_i, match[3].to_i, match[5].to_i, match[6].to_i, match[7].to_i)
    elsif match = timestr_t.match(/^([A-z]+),\s*(\d+)\s+([A-z]+)\s+(\d+)\s+(\d+):(\d+):(\d+)\s*([A-z]+)$/)
      return Datet.new(match[4].to_i, Datet.month_str_to_no(match[3]), match[2].to_i, match[5].to_i, match[6].to_i, match[7].to_i)
    end
    
    raise ArgumentError, "Wrong format: '#{timestr}', class: '#{timestr.class.name}'"
  end
  
  #Returns a hash with the month-no as key and month-name as value. It uses the method "_" to translate the months names. So GetText or another method has to be defined.
  def self.months(args = nil)
    if args
      args.each do |key, val|
        case key
          when :short, :trans
          else
            raise ArgumentError, "Invalid key in arguments: '#{key}'."
        end
      end
    end
    
    ret = @@month_names.clone
    
    if args
      if args[:trans]
        ret.each do |key, val|
          ret[key] = _(val)
        end
      end
      
      if args[:short]
        ret_short = {}
        ret.each do |key, val|
          ret_short[key] = val[0..2]
        end
        
        return ret_short
      end
    end
    
    return ret
  end
  
  #Returns a hash with the day-number as value (starting with 1 for monday). It uses the method "_" to translate the months names.
  #===Examples
  # Datet.days #=> {0=>"Sunday", 1=>"Monday", 2=>"Tuesday", 3=>"Wednesday", 4=>"Thursday", 5=>"Friday", 6=>"Saturday"}
  # Datet.days(:mfirst => true) #=> {0=>"Monday", 1=>"Tuesday", 2=>"Wednesday", 3=>"Thursday", 4=>"Friday", 5=>"Saturday", 6=>"Sunday"}
  def self.days(args = nil)
    if args
      args.each do |key, val|
        case key
          when :mfirst, :short, :trans
          else
            raise ArgumentError, "Unknown key in arguments: '#{key}'."
        end
      end
    end
    
    ret = @@day_names.clone
    
    if args
      if args[:trans]
        ret.each do |key, val|
          ret[key] = _(val)
        end
      end
      
      if args[:mfirst]
        newret = {}
        ret.each do |key, val|
          next if key == 0
          newret[key - 1] = val
        end
        newret[6] = ret[0]
        ret = newret
      end
    
      if args[:short]
        ret_short = {}
        ret.each do |key, val|
          ret_short[key] = val[0..2]
        end
        
        ret = ret_short
      end
    end
    
    return ret
  end
  
  #Converts a given day-name to the right day number.
  #===Examples
  # Datet.day_str_to_no('wed') #=> 3
  def self.day_str_to_no(day_str, args = nil)
    day_str = day_str.to_s.strip[0, 3]
    
    if no = @@days_lcase[day_str]
      if args and args[:mfirst]
        if no == 0
          no = 6
        else
          no -= 1
        end
      end
      
      return no
    end
    
    raise ArgumentError, "Invalid day-string: '#{day_str}'."
  end
  
  #Returns the month-number for a given string (starting with 1 for january).
  #===Examples
  # Datet.month_str_to_no("JaNuArY") #=> 1
  # Datet.month_str_to_no("DECEMBER") #=> 12
  # Datet.month_str_to_no("kasper") #=> <Error>-raised
  def self.month_str_to_no(str)
    str = str.to_s.downcase.strip
    return @@months_lcase[str] if @@months_lcase.key?(str)
    raise ArgumentError, "No month to return from that string: '#{str}'."
  end
  
  #This returns a code-string that can be used to recreate the Datet-object.
  #===Examples
  # code = datet.code #=> "1985061710000000000"
  # newdatet = Datet.in(code) #=> 1985-06-17 10:00:00 +0200
  def code
    return "#{"%04d" % @t_year}#{"%02d" % @t_month}#{"%02d" % @t_day}#{"%02d" % @t_hour}#{"%02d" % @t_min}#{"%02d" % @t_sec}#{"%05d" % @t_usec}"
  end
  
  #Returns the unix timestamp for this object (uses 'Time' to calculate).
  #===Examples
  # datet.to_i #=> 487843200
  def to_i
    return self.time.to_i
  end
  
  #Returns the unix timestamp for this object as a float (uses 'Time' to calculate).
  #===Examples
  # Datet.new.to_f #=> 1342381158.0
  def to_f
    return self.time.to_f
  end
  
  #Returns a string that describes the object.
  def to_s
    return "#{"%04d" % @t_year}-#{"%02d" % @t_month}-#{"%02d" % @t_day} #{"%02d" % @t_hour}:#{"%02d" % @t_min}:#{"%02d" % @t_sec}"
  end
  
  #Returns arguments in an array.
  def to_a
    return [@t_year, @t_month, @t_day, @t_hour, @t_min, @t_sec, @t_usec]
  end
  
  #Returns the HTTP-date that can be used in headers and such.
  #===Examples
  # datet.httpdate #=> "Mon, 17 Jun 1985 08:00:00 GMT"
  def httpdate
    return "#{self.day_name[0, 3]}, #{@t_day} #{self.month_name[0, 3]} #{@t_year} #{"%02d" % @t_hour}:#{"%02d" % @t_min}:#{"%02d" % @t_sec} GMT"
  end
  
  #Returns various information about the offset as a hash.
  #===Examples
  # datet.time #=> 1985-06-17 10:00:00 +0200
  # datet.offset_info #=> {:sign=>"+", :hours=>2, :mins=>0, :secs=>0}
  def offset_info
    offset_secs = self.time.gmt_offset
    
    offset_hours = (offset_secs.to_f / 3600.0).floor
    offset_secs -= offset_hours * 3600
    
    offset_minutes = (offset_secs.to_f / 60.0).floor
    offset_secs -= offset_minutes * 60
    
    if offset_hours > 0
      sign = "+"
    else
      sign = ""
    end
    
    return {
      :sign => sign,
      :hours => offset_hours,
      :mins => offset_minutes,
      :secs => offset_secs
    }
  end
  
  #Returns the offset as a string.
  #===Examples
  # datet.offset_str #=> "+0200"
  def offset_str
    offset_info_data = self.offset_info
    return "#{offset_info_data[:sign]}#{"%02d" % offset_info_data[:hours]}#{"%02d" % offset_info_data[:mins]}"
  end
  
  #Returns 'localtime' as of 1.9 - even in 1.8 which does it different.
  #===Examples
  # datet.localtime_str #=> "1985-06-17 10:00:00 +0200"
  def localtime_str
    return "#{"%04d" % @t_year}-#{"%02d" % @t_month}-#{"%02d" % @t_day} #{"%02d" % @t_hour}:#{"%02d" % @t_min}:#{"%02d" % @t_sec} #{self.offset_str}"
  end
  
  #Returns a human readable string based on the difference from the current time and date.
  #===Examples
  # datet.time #=> 1985-06-17 10:00:00 +0200
  # datet.ago_str #=> "27 years ago"
  # datet = Datet.new #=> 2012-05-03 20:31:58 +0200
  # datet.ago_str #=> "18 seconds ago"
  def ago_str(args = {})
    args = {
      :year_ago_str => "%s year ago",
      :years_ago_str => "%s years ago",
      :month_ago_str => "%s month ago",
      :months_ago_str => "%s months ago",
      :day_ago_str => "%s day ago",
      :days_ago_str => "%s days ago",
      :hour_ago_str => "%s hour ago",
      :hours_ago_str => "%s hours ago",
      :min_ago_str => "%s minute ago",
      :mins_ago_str => "%s minutes ago",
      :sec_ago_str => "%s second ago",
      :secs_ago_str => "%s seconds ago",
      :right_now_str => "right now"
    }.merge(args)
    
    secs_ago = Time.now.to_i - self.to_i
    
    mins_ago = secs_ago.to_f / 60.0
    hours_ago = mins_ago / 60.0
    days_ago = hours_ago / 24.0
    months_ago = days_ago / 30.0
    years_ago = months_ago / 12.0
    
    if years_ago > 0.9 and years_ago < 1.5
      return sprintf(args[:year_ago_str], years_ago.to_i)
    elsif years_ago >= 1.5
      return sprintf(args[:years_ago_str], years_ago.to_i)
    elsif months_ago > 0.9 and months_ago < 1.5
      return sprintf(args[:month_ago_str], months_ago.to_i)
    elsif months_ago >= 1.5
      return sprintf(args[:months_ago_str], months_ago.to_i)
    elsif days_ago > 0.9 and days_ago < 1.5
      return sprintf(args[:day_ago_str], days_ago.to_i)
    elsif days_ago >= 1.5
      return sprintf(args[:days_ago_str], days_ago.to_i)
    elsif hours_ago > 0.9 and hours_ago < 1.5
      return sprintf(args[:hour_ago_str], hours_ago.to_i)
    elsif hours_ago >= 1.5
      return sprintf(args[:hours_ago_str], hours_ago.to_i)
    elsif mins_ago > 0.9 and mins_ago < 1.5
      return sprintf(args[:min_ago_str], mins_ago.to_i)
    elsif mins_ago >= 1.5
      return sprintf(args[:mins_ago_str], mins_ago.to_i)
    elsif secs_ago >= 0.1 and secs_ago < 1.5
      return sprintf(args[:sec_ago_str], secs_ago.to_i)
    elsif secs_ago >= 1.5
      return sprintf(args[:secs_ago_str], secs_ago.to_i)
    end
    
    return args[:right_now_str]
  end
  
  #Returns the object as a human understandable string.
  #===Examples
  # datet.time #=> 2012-05-03 20:31:58 +0200
  # datet.human_str #=> "20:31"
  def human_str(args = {})
    args = {
      :time => true,
      :number_endings => {
        0 => "th",
        1 => "st",
        2 => "nd",
        3 => "rd",
        4 => "th",
        5 => "th",
        6 => "th",
        7 => "th",
        8 => "th",
        9 => "th"
      }
    }.merge(args)
    
    now = Time.now
    
    #Generate normal string.
    date_str = ""
    
    if now.day != @t_day and now.month == @t_month and now.year == @t_year
      last_digit = @t_day.to_s[-1, 1].to_i
      
      if ending = args[:number_endings][last_digit]
        #ignore.
      else
        ending = "."
      end
      
      date_str << "#{@t_day}#{ending} "
    elsif now.day != @t_day or now.month != @t_month or now.year != @t_year
      date_str << "#{@t_day}/#{@t_month} "
    end
    
    if now.year != @t_year
      date_str << "#{@t_year} "
    end
    
    if args[:time]
      date_str << "#{@t_hour}:#{"%02d" % @t_min}"
    end
    
    return date_str
  end
  
  #See the documentation for Time#strftime. It emulates that method.
  #This method is not complete yet and only contains some functionality.
  def strftime(str)
    replaces = {}
    res = "#{str}"
    
    str.scan(/(%%|%(\^|)([A-z]))/) do |match|
      #The does the functionality of actually having a '%' in the string.
      if match[0] == "%%"
        replaces["%%"] = "%"
        next
      end
      
      #Set up replace-hash for later replace.
      bigsign = match[1]
      letter = match[2]
      
      le = "%#{bigsign}#{letter}"
      
      #Skip if letter has already been set.
      next if replaces.key?(le)
      
      case letter
        when "Y"
          replaces[le] = @t_year
        when "m"
          replaces[le] = "%02d" % @t_month
        when "d"
          replaces[le] = "%02d" % @t_day
        when "e"
          replaces[le] = @t_day
        when "H"
          replaces[le] = "%02d" % @t_hour
        when "k"
          replaces[le] = @t_hour
        when "l"
          replaces[le] = self.hour_thc
        when "I"
          replaces[le] = "%02d" % self.hour_thc
        when "M"
          replaces[le] = "%02d" % @t_min
        when "S"
          replaces[le] = "%02d" % @t_sec
        when "T"
          replaces[le] = "#{"%02d" % @t_hour}:#{"%02d" % @t_min}:#{"%02d" % @t_sec}"
        when "R"
          replaces[le] = "#{"%02d" % @t_hour}:#{"%02d" % @t_min}"
        when "r"
          replaces[le] = "#{"%02d" % self.hour_thc}:#{"%02d" % @t_min}:#{"%02d" % @t_sec} #{self.ampm.upcase}"
        when "B"
          replaces[le] = self.month_name
        when "b", "h"
          replaces[le] = self.month_name[0, 3]
        when "j"
          replaces[le] = self.day_of_year
        when "A"
          replaces[le] = self.day_name
        when "a"
          replaces[le] = self.day_name[0, 3]
        when "w"
          replaces[le] = self.day_in_week
        when "u"
          replaces[le] = self.day_in_week(:mfirst => true) + 1
        when "s"
          replaces[le] = self.to_i
        when "p"
          replaces[le] = self.ampm.upcase
        when "P"
          replaces[le] = self.ampm
        when "V"
          replaces[le] = self.week_no
        when "W"
          replaces[le] = self.week_no(:mfirst => true)
      end
      
      #Replace should be uppercase.
      if bigsign == "^" and replaces.key?(le)
        replaces[le] = replaces[le].to_s.upcase
      end
    end
    
    #Do the actual replaces.
    replaces.each do |key, val|
      res = res.gsub(key, val.to_s)
    end
    
    #Return the replaced string.
    return res
  end
end