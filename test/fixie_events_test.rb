require File.join( File.dirname(__FILE__), 'test_helper' )

class FixieEventsTest < ActiveSupport::TestCase
  def test_events
    assert Event.all.blank?
  end
  
  def test_interval_constants
    Event.create! :start_at => DateTime.now
  end

  def test_this
    assert 1 == 1
  end
end
