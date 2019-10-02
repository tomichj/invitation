module Invitation
  # Make invitation available to Rails apps on initialization.
  #
  # Requiring `invitation` (likely by having it in your `Gemfile`) will
  # automatically require the engine.
  #
  # Invitation provides:
  # * routes
  # * controllers
  # * views
  #
  # You can opt-out of Invitation's internal routes by using {Configuration#routes=}. You can
  # subclass controllers, and override the Invitation views by running `rails generate invitation:views`.
  class Engine < ::Rails::Engine
    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end
  end
end
