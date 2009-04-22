require 'test_helper'

class FixieEventsTest < ActiveSupport::TestCase
  def test_events
    assert Event.all.blank?
  end

  def test_this
    assert 1 == 1
  end
end
