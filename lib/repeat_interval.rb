class RepeatInterval < ActiveRecord::Base
  has_many :events

  def expression
    send( self.abrev.downcase )
  end
  
  
  def self.options_for_select
    find( :all ).collect{ |ri| [ri.name, ri.abrev] }
  end
private
  def self.weekend date
    Runt::REWeek.new( Runt::Saturday, Runt::Sunday)
  end
  
  def self.weekly date
    Runt::DIWeek.new(date.wday)                  
  end
  
  def self.weekday date
    Runt::DIWeekday.new(date.wday)                  
  end

end
