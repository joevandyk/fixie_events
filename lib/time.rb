class Time
  # Returns the number of week of the month that this is.  i.e. April 13th, 2009 is the 3rd week of April
  def week_of_month
    t = self.dup
    d = t.mday
    count = 1
    while t.mday <= d do
      t = t - 7.days
      count += 1
    end
    count
  end
end

