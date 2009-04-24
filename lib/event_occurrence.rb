# TODO move out of here
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

class EventOccurrence < ActiveRecord::Base
  belongs_to :event
  belongs_to :reapeat_interval

=begin
  delegate :dance_types, :to => :event
  delegate :address_city_state, :to => :event
  delegate :user, :to => :event
  delegate :picture, :to => :event
  delegate :get_picture, :to => :event
  delegate :description, :to => :event
  delegate :user_id, :to => :event
  delegate :name, :to => :event
=end

  def self.for_range start_at, end_at
    # TODO Later, instead of looping over all events (inefficient), 
    # keep track if we've already generated occurrences for the events for 
    # that particular month.
    Event.all.map do |event|
      if event.repeats?
        occurrences_for_repeating_event(event, start_at, end_at)
      else 
        occurrence_for_single_event(event, start_at, end_at)
      end
    end.flatten.reject { |a| a.nil? }.sort { |a, b| a.start_at <=> b.start_at }
  end

  # Returns a flat array of all event occurrences that happen in the specified month.
  def self.for_month month
    for_range(month, month >> 1)
  end

  private

  def self.occurrence_for_single_event event, start_at, end_at
    if event.start_at >= start_at and event.start_at < end_at
      find_or_create_event_by_day(event, pday(event.start_at))
    end
  end

  def self.occurrences_for_repeating_event event, start_at, end_at=nil
    # Setup repeating runt expression
    s = event.repeat_interval.expression( event.start_at )
    
    # If ranged end date
    if end_at
      s = s & before(end_at)
    end

    # Apply start date
    s = s & after(event.start_at)

    # If end date, apply it
    if event.events_end_at
      s = s & before(event.events_end_at)
    end

    # Get the days in the range
    date_range = range(start_at, end_at)

    # Loop over the days in the month that the event falls on,
    # Find or create the occurrence for that day.
    s.dates(date_range).map do |day|
      find_or_create_event_by_day(event, day)
    end
  end
  
  # Given an event and a day, find the event occurrence for that day
  def self.find_or_create_event_by_day event, day
    event.occurrences.find(:first, :conditions => ["start_at >= ? and start_at < ?", day, day + 1]) \
      or
    event.create_occurrence_on(day)
  end

  # Runt Helpers below
  def self.sugar 
    ExpressionBuilder.new
  end

  def self.pday date
    Runt::PDate.day date.year, date.month, date.day 
  end

  def self.pweek date
    Runt::PDate.week date.year, date.month, date.day
  end

  def self.after date
    Runt::AfterTE.new(pday(date), true)
  end

  def self.before date
    Runt::BeforeTE.new(pday(date), true)
  end

  def self.range start_at, end_at
    Runt::DateRange.new(pday(start_at), pday(end_at))
  end
  
  def self.monthly date
    Runt::DIMonth.new(date.week_of_month, date.wday) 
  end
end
