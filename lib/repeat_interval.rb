class RepeatInterval < ActiveRecord::Base
  has_many :events

  def expression start_date
    send( abrev.downcase.to_sym, start_date )
  end
  
  def self.options_for_select
    find( :all ).collect{ |ri| [ri.name, ri.abrev] }
  end
  
  def weekend date
    Runt::REWeek.new( Runt::Saturday, Runt::Sunday)
  end
  
  def weekly date
    Runt::DIWeek.new(date.wday)                  
  end
  
  def weekday date
    Runt::DIWeekday.new(date.wday)                  
  end

end
