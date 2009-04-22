class CreateRepeatIntervals < ActiveRecord::Migration
  def self.up
    create_table :repeat_intervals do |t|
        t.string  'abrev'
        t.string  :name
        t.integer :order
        t.timestamps
      end

      [
        [ 'DAILY',       'Daily	Daily',	           2],
        [ 'MONTHLY',     'Monthly	Monthly',	       8],
        [ 'MON_WED_FRI', 'Every Mon., Wed.',       4],
        [ 'NONE',        'Does not repeat',	       1],
        [ 'TUE_THU',     'Every Tues. and Thurs.', 5],
        [ 'WEEKLY',      'Weekly',	               7],
        [ 'WEEKDAYS',	   'Week Days',	             3],
        [ 'WEEKENDS',	   'Weekends',	             6],
        [ 'YEARLY',	     'Yearly',	               9]
      ].each do |interval| 
         RepeatInterval.create :abrev => interval[0], :name => interval[1], :order => interval[2]
      end
  end

  def self.down
    drop_table :repeat_intervals
  end
end
