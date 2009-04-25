class RepeatInterval < ActiveRecord::Base
  has_many :events
  
  include Runt 
  
  def expression start_date
    send( abrev.downcase.to_sym, start_date )
  end
  
  def self.options_for_select
    find( :all ).collect{ |ri| [ri.name, ri.abrev] }
  end
  
  def none  
    nil
  end
   
  def daily
    
  end
    
  def weekend date
    Runt::REWeek.new( Runt::Saturday, Runt::Sunday)
  end
  
  def weekly date
    DIWeek.new(date.wday)                  
  end
  
  def weekday date
    DIWeekday.new(date.wday)                  
  end

  def monthly date
    DIMonth.new(date.week_of_month, date.wday) 
  end
  
  def mon_wed_fri date
    DIWeek.new( Mon ) | DIWeek.new( Wed ) | DIWeek.new( Fri )
  end

  
  def tue_thu date
    DIWeek.new( Tues ) | DIWeek.new( Thurs )
  end
    
  
  def yearly date  
    REYear( date.mday, date.wday, date.mday, date.wday )
  end 
  
  
end
