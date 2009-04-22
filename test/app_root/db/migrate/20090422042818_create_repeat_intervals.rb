class CreateRepeatIntervals < ActiveRecord::Migration
  def self.up
    create_table :repeat_intervals do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :repeat_intervals
  end
end
