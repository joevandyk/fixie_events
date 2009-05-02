require 'lib/event'
$: << File.join(File.dirname(__FILE__), "lib", "runt", "lib")
require 'runt'
Event.set_repeat_interval_constants
