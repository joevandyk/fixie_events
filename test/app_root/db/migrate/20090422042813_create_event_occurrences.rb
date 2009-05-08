class CreateEventOccurrences < ActiveRecord::Migration
  def self.up
    create_table :event_occurrences do |t|
       t.integer  :event_id
       t.string   :name
       t.datetime :start_at
       t.datetime     :begin_time
       t.datetime     :end_at
       t.timestamps
    end
  end

  def self.down
    drop_table :event_occurrences
  end
end
