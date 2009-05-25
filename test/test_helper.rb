# Set the default environment to sqlite3's in_memory database
ENV['RAILS_ENV'] ||= 'in_memory'

# Load the Rails environment and testing framework
require "#{File.dirname(__FILE__)}/app_root/config/environment"
require 'test_help'
require 'action_view/test_case' # Load additional test classes not done automatically by < Rails 2.2.2
require 'rubygems'

#allow to be run in test fold ala TextMate
Dir["../lib/*"].each do |f|  
 require File.join( File.dirname(__FILE__), f )
end

$: << File.join(File.dirname(__FILE__), "..", "vendor", "shoulda", "lib")
$: << File.join(File.dirname(__FILE__), "..", "lib", "runt", "lib")
require File.join( File.dirname(__FILE__), "..", "vendor", "shoulda", "init" )

# Undo changes to RAILS_ENV
silence_warnings {RAILS_ENV = ENV['RAILS_ENV']}

# Run the migrations
ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate")

# Set default fixture loading properties
if Test::Unit::TestCase.respond_to?(:use_transactional_fixtures)
  Test::Unit::TestCase.class_eval do
    self.use_transactional_fixtures = true
    self.use_instantiated_fixtures = false
    self.fixture_path = "#{File.dirname(__FILE__)}/fixtures"
  end
else
  ActiveSupport::TestCase.class_eval do
    self.use_transactional_fixtures = true
    self.use_instantiated_fixtures = false
    self.fixture_path = "#{File.dirname(__FILE__)}/fixtures"
  end
end
