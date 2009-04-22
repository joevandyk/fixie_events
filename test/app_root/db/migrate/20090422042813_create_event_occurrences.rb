class CreateEventOccurrences < ActiveRecord::Migration
  def self.up
    create_table :event_occurrences do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :event_occurrences
  end
end
