class Event < ActiveRecord::Base
  has_many     :occurrences, :class_name => "EventOccurrence", :dependent => :destroy
  belongs_to   :repeat_interval
                                             
  after_update :update_occurrences

  def repeats?
    repeat_interval and (repeat_interval.abrev != 'NONE')
  end

  # Given a day, create an occurrence based on this event for that particular day.
  def create_occurrence_on day
    day = day.to_time.utc
    o = EventOccurrence.new
    o.event = self
    o.start_at = day + self.start_at.hour.hours + self.start_at.min.minutes 
    if self.end_at
      o.end_at = day + self.end_at.hour.hours + self.end_at.min.minutes
   end

    o.save!
    o
  end

  private

  def update_occurrences
    # Remove any occurrences after the events_end_at
    if self.events_end_at
      EventOccurrence.destroy_all ["start_at > ? and event_id = ?", self.events_end_at, self.id]
    end

    # Remove any occurrences before the start_at
    EventOccurrence.destroy_all ["start_at < ? and event_id = ?", self.start_at, self.id]
  end
  
  
  def self.set_repeat_interval_constants
    RepeatInterval.find( :all ).each do |ri|
      Event.const_set ri.abrev.upcase, ri.id
    end rescue 'Run recurring even migrations'
  end
end
