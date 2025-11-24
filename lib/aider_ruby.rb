require_relative 'aider_ruby/version'

module AiderRuby
  class Error < StandardError; end
end

require_relative 'aider_ruby/error_handling'
require_relative 'aider_ruby/validation'
require_relative 'aider_ruby/constants'
require_relative 'aider_ruby/task'
require_relative 'aider_ruby/client'
require_relative 'aider_ruby/config'
require_relative 'aider_ruby/models'
require_relative 'aider_ruby/task_executor'

module AiderRuby
  # Main entry point for the gem
  def self.new_client(options = {}, &block)
    Client::Client.new(options, &block)
  end

  def self.configure(&block)
    Config::Configuration.configure(&block)
  end

  def self.version
    VERSION
  end

  # NOTE: Use AiderRuby::Client::Client and AiderRuby::Config::Configuration directly
  # Aliases are available but may cause warnings
end
