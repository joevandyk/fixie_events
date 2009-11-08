require File.join( File.dirname(__FILE__), 'test_helper' )

class FixieEventsTest < ActiveSupport::TestCase
  FEB       = Time.local(2009, 2)
  MARCH     = Time.local(2009, 3)
  APRIL     = Time.local(2009, 4)
  MARCH_29  = Time.local(2009, 3, 29, 19, 30)
  APRIL_19  = Time.local(2009, 4, 19)
  APRIL_13  = Time.local(2009, 4, 13)
  WED_APR_22= Time.local(2009, 4, 22)
  MAY       = Time.local(2009, 5)
  FRI_MAY_1 = Time.local(2009, 5, 1)
  SEPTEMBER = Time.local(2009, 9, 30)
  OCTOBER   = Time.local(2009, 10)

  context "Recurring Events" do
    setup do
      Event.destroy_all
    end

    context "monthly event on 3rd monday until september" do
      setup do
        @event = Event.create! :start_at => APRIL_13, :end_at => APRIL_13, :repeat_interval_id => Event::WEEKLY, :events_end_at => SEPTEMBER
      end

      should "should have one event per month on the 3rd Monday" do
        month = APRIL
        while month <= SEPTEMBER
          occurrences = EventOccurrence.for_month(month)
          assert ( 3 <= occurrences.size  or  5 >= occurrences.size )   
          month = month.advance :months => 1
        end
        
        { 1 => Time.local(2009, 4, 20),
          5 => Time.local(2009, 5, 18),
          9 => Time.local(2009, 6, 15)
        }.each do |occurrence_id, date|
          #puts "->llll -#{occurrence_id}- #{APRIL_13.hour } <-> #{APRIL_13.advance( :hours => 1).hour} <-> #{@event.occurrences[occurrence_id].start_at.hour}"
          assert_occurrence_at_date occurrence_id, date
        end
        
        assert 0 == EventOccurrence.for_month(OCTOBER).size, "october out of range"
      end
      
      should "should have an expression of DIWeek" do
        assert @event.repeat_interval.expression( APRIL ).class == Runt::DIWeek
      end
      
      should "should have a repeat interval" do
        @event.repeat_interval.id == Event::WEEKLY
      end
    end
  
    context "mon wed fri " do
      setup do
        @event = Event.create! :start_at => APRIL_13, :end_at => APRIL_13.advance( :hours => 1 ), :repeat_interval_id => Event::MON_WED_FRI, :events_end_at => MAY
      end
      
      should "be repeating" do
        assert @event.repeats?
      end
      
      should "should exist on the first monday some wednesday and much later on friday" do
        occurrences = EventOccurrence.for_range( MARCH, MAY )

        { 0 => APRIL_13,
          4 => WED_APR_22,
          8 => FRI_MAY_1  
        }.each do |occurrence_id, date|
          assert_occurrence_at_date occurrence_id, date
         end
      
      end
    end # m w f
  end
  
  context "Event repeating constants" do
    setup do
      Event.set_repeat_interval_constants
    end
    
    should " should contain none, weekly, and yearly" do
      assert( Event::NONE   == 4)
      assert( Event::YEARLY == 9)
      assert( Event::WEEKLY == 6)
    end
  end

  context "Non-recurring event" do
    should "should have a single occurrence" do
      event = Event.create! :start_at => MARCH_29, :end_at => MARCH_29.advance( :hours => 1 )
      
      occurrences = EventOccurrence.for_month(MARCH)
      assert 1 == occurrences.size, " #{occurrences.size} should have been 1"
      assert occurrences.first.start_at == event.start_at, "s #{occurrences.first.start_at} == #{event.start_at}"
      assert occurrences.first.end_at   == event.end_at,   "e #{occurrences.first.end_at} == #{event.end_at}"
    end
  end
  
  
  def assert_occurrence_at_date o, date, occurrences = nil
    occurrences ||= @event.occurrences
    start_date = occurrences[o].start_at
    assert start_date == date,
           " start occurrence[#{o}] #{start_date.class}-#{start_date.strftime( '%m/%d/%y %H:%M:%S %z')} didn't match #{date.class} #{date.strftime( '%m/%d/%y %H:%M:%S %z')} "
  end  
  alias :assert_occurrence_at_start_date :assert_occurrence_at_date 
  
  def assert_occurrence_at_end_date o, date, occurrences = nil
    occurrences ||= @event.occurrences
    end_date =  occurrences[o].end_at
    assert end_date == date,
           " end occurrence[#{o}] #{end_date.strftime('%m/%d/%y %H:%M')} didn't match #{date.strftime( '%m/%d/%y %H:%M')}"
  end
  context "Weekly event starting in march without end" do
    setup do
      @event = Event.create! :start_at => MARCH_29, :end_at => MARCH_29.advance( :hours => 1 ), :repeat_interval_id => Event::WEEKLY
      @april = EventOccurrence.for_month(APRIL)
    end

    should "should have four events in april" do
      EventOccurrence.for_month(APRIL).size == 4
    end
    
    should "should have one event if ranged for one day" do
      assert_equal 1, EventOccurrence.for_range(MARCH_29, MARCH_29.advance( :day => 1 ) ).size
    end
    
    should "should have 52 events if ranged for a year" do
      assert_equal 53, EventOccurrence.for_range(MARCH_29, MARCH_29.advance( :weeks => 52 ) ).size
    end
  
    should "the created occurrences should be attached to the event, and have the same times for starting and ending" do
      { 0 => { :start_at => Time.local(2009, 4,  5, 19, 30),
             :end_at   => Time.local(2009, 4,  5, 20, 30)},
                                                    
        1 => { :start_at => Time.local(2009, 4, 12, 19, 30),
             :end_at   => Time.local(2009, 4, 12, 20, 30) },
                                                
        2 => { :start_at => Time.local(2009, 4, 19, 19, 30),
             :end_at   => Time.local(2009, 4, 19, 20, 30) },
                                                    
        3 => { :start_at => Time.local(2009, 4, 26, 19, 30),
             :end_at   => Time.local(2009, 4, 26, 20, 30) }
      }.each do |occurrence_id, date_range |
        assert_occurrence_at_start_date occurrence_id, date_range[:start_at], @april
        assert_occurrence_at_end_date   occurrence_id, date_range[:end_at  ], @april
      
      end
    end
  end
  
  
end

=begin
# These are left to convert
describe "Recurring Events" do
  describe "weekly event starting in march without end" do
   

    it "the created occurrences should be attached to the event, and have the same times for starting and ending" do
      april_events = EventOccurrence.for_month(APRIL)
      april_events[0].start_at.should == Time.local(2009, 4,  5, 19, 30)
      april_events[0].end_at.  should == Time.local(2009, 4,  5, 20, 30)

      april_events[1].start_at.should == Time.local(2009, 4, 12, 19, 30)
      april_events[1].end_at.  should == Time.local(2009, 4, 12, 20, 30)

      april_events[2].start_at.should == Time.local(2009, 4, 19, 19, 30)
      april_events[2].end_at.  should == Time.local(2009, 4, 19, 20, 30)

      april_events[3].start_at.should == Time.local(2009, 4, 26, 19, 30)
      april_events[3].end_at.  should == Time.local(2009, 4, 26, 20, 30)
    end

    it "shouldn't create new events on subsequent calls" do
      assert_difference "EventOccurrence.count", 0 do 
        @april.should == EventOccurrence.for_month(APRIL)
      end
    end

    it "should be able to find events in far future" do
      assert_difference "EventOccurrence.count", 4 do 
        EventOccurrence.for_month(APRIL + 1.year).size.should == 4
      end
    end

    it "should be one event in march" do
      EventOccurrence.for_month(MARCH).size.should == 1
    end

    it "should be no events in feb" do
      EventOccurrence.for_month(FEB).should be_blank
    end

    it "deleting the event should delete the occurrences" do
      @event.destroy
      @april.each { |o| lambda { o.reload }.should raise_error }
    end

    it "making the end date earlier should remove the occurrences after the new end date" do
      @event.events_end_at = APRIL_19
      @event.save!

      # The last event should have been removed
      lambda { @april.last.reload }.should raise_error
    end

    it "shouldn't delete occurrences for other events when changing the end date" do
      other_event = Event.create! :start_at => MARCH_29, :end_at => MARCH_29 + 1.hour, :repeat_weekly => true
      EventOccurrence.for_month(APRIL)
      other_occurrences = other_event.reload.occurrences
      other_occurrences.should_not be_blank

      @event.events_end_at = APRIL_19
      @event.save!
     
      # Ensure that no other event had their occurrences deleted
      other_occurrences.each { |e| e.reload }
    end

    it "should delete previous occurences if start date moved forward" do
      @event.occurrences.find(:all, :conditions => ["start_at < ?", APRIL_19]).should_not be_blank
      @event.update_attribute :start_at, APRIL_19
      # There shouldn't be any events after April 19th
      @event.occurrences.find(:all, :conditions => ["start_at < ?", APRIL_19]).should be_blank
    end
  end

  describe "weekly event starting in march ending midway through april" do
    it "should have three events in april (not 4)" do
      event = Event.create! :start_at => MARCH_29, :repeat_weekly => true, :end_at => MARCH_29 + 1.hour, :events_end_at => APRIL_19
      april = EventOccurrence.for_month(APRIL)
      april.size.should == 3
    end
  end

end


=end
