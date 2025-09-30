#!/usr/bin/env ruby
# Example usage of AiderRuby

require 'aider_ruby'

# Example 1: Basic usage
puts '=== Example 1: Basic Usage ==='
client = AiderRuby.new_client(
  model: 'claude-3-5-sonnet-20241022',
  verbose: true
)

client
  .add_file('app/models/user.rb')
  .add_read_only_file('README.md')
  .dark_mode(true)
  .auto_commits(true)

# Example 2: Configuration from file
puts "\n=== Example 2: Configuration from File ==="
AiderRuby::Config.load_from_file('config/aider.yml.example')
AiderRuby::Config.load_from_env_file('.env')

client2 = AiderRuby.new_client
puts "Model: #{client2.config.model}"
puts "Dark mode: #{client2.config.dark_mode}"

# Example 3: Model information
puts "\n=== Example 3: Model Information ==="
models = AiderRuby::Models.list_models(:openai)
puts "OpenAI models: #{models.join(', ')}"

info = AiderRuby::Models.model_info('gpt-4o')
puts 'GPT-4o info:'
puts "  Provider: #{info[:provider]}"
puts "  Context: #{info[:context_window]} tokens"
puts "  Vision: #{info[:vision]}"
puts "  Reasoning: #{info[:reasoning]}"

# Example 4: Task execution
puts "\n=== Example 4: Task Execution ==="
executor = AiderRuby::TaskExecutor.new(client)

# This would execute a real task (commented out for demo)
# result = executor.execute_coding_task(
#   "Create a User model with validations",
#   ['app/models/user.rb']
# )

puts 'Task executor created successfully'

# Example 5: Recommended models
puts "\n=== Example 5: Recommended Models ==="
recommended = AiderRuby::Models.recommended_models
recommended.each do |category, model|
  puts "#{category.to_s.gsub('_', ' ').capitalize}: #{model}"
end

puts "\n=== Examples completed ==="
