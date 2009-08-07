require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.cache_classes = false
  config.whiny_nils = true
  config.time_zone = "UTC"
  config.action_controller.session = { :key => "_myapp_session", :secret => "some secret phrassome secret phrassome secret phrassome secret phrassome secret phrassome secret phraseeeeeesome secret phrase" }
  config.plugin_locators.unshift(
    Class.new(Rails::Plugin::Locator) do
      def plugins
        [Rails::Plugin.new(File.expand_path('.'))]
      end
    end
  ) unless defined?(PluginTestHelper::PluginLocator)
end
