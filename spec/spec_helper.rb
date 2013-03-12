require 'capistrano-spec'

#TODO make pull-request into capistrano-spec gem
require 'support/matchers'
require 'support/configuration_extension'

RSpec.configure do |config|
  config.include Capistrano::Spec::Matchers
  config.include Capistrano::Spec::Helpers
  config.include Matchers
  config.order = :random
end
