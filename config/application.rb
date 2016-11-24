require_relative 'boot'

# require 'rails/all'  -- commented
require "action_controller/railtie"
require "action_mailer/railtie"
#require "active_resource/railtie" no need
#require "rails/test_unit/railtie" no need
#require "sprockets/railtie" no need

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Telemetry
 class Application < Rails::Application
   
     config.after_initialize do
    # Do not copy the plugin assets into public folder every time.
    [
      File.join(Rails.root, 'lib', '*.rb'),
    ].each do |path|
      Dir.glob(path).each do |file|
        require_dependency file
      end
    end
  end
     #config.app_middleware.delete "ActiveRecord::ConnectionAdapters::ConnectionManagement"
  end
end
