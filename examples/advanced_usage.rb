#!/usr/bin/env ruby
# Advanced usage examples for AiderRuby

require 'aider_ruby'

# Example 1: Multi-step refactoring task
puts '=== Advanced Example 1: Multi-step Refactoring ==='

client = AiderRuby.new_client(
  model: 'claude-3-5-sonnet-20241022',
  anthropic_api_key: ENV['ANTHROPIC_API_KEY'],
  dark_mode: true,
  auto_commits: true,
  lint: true,
  auto_lint: true
)

executor = AiderRuby::TaskExecutor.new(client)

# Multi-step refactoring
steps = [
  'Analyze the current User model and identify areas for improvement',
  'Apply SOLID principles to refactor the User model',
  'Create comprehensive tests for the refactored User model',
  'Update documentation to reflect the changes'
]

files = ['app/models/user.rb', 'app/controllers/users_controller.rb']

puts 'Executing multi-step refactoring task...'
# result = executor.execute_multi_step_task(steps, files)

# Example 2: Debugging with verbose output
puts "\n=== Advanced Example 2: Debugging Task ==="

debugging_client = AiderRuby.new_client(
  model: 'gpt-4o',
  openai_api_key: ENV['OPENAI_API_KEY'],
  verbose: true,
  show_diffs: true,
  test: true,
  auto_test: true
)

debugging_executor = AiderRuby::TaskExecutor.new(debugging_client)

puts 'Executing debugging task...'
# result = debugging_executor.execute_debugging_task(
#   "Fix the authentication bug in the login system",
#   ['app/controllers/sessions_controller.rb', 'app/models/user.rb']
# )

# Example 3: Documentation generation
puts "\n=== Advanced Example 3: Documentation Generation ==="

doc_client = AiderRuby.new_client(
  model: 'claude-3-5-sonnet-20241022',
  anthropic_api_key: ENV['ANTHROPIC_API_KEY'],
  pretty: true,
  stream: true
)

doc_executor = AiderRuby::TaskExecutor.new(doc_client)

puts 'Executing documentation task...'
# result = doc_executor.execute_documentation_task(
#   "Create comprehensive API documentation for the User model",
#   ['app/models/user.rb', 'app/controllers/users_controller.rb']
# )

# Example 4: Test generation with specific framework
puts "\n=== Advanced Example 4: Test Generation ==="

test_client = AiderRuby.new_client(
  model: 'claude-3-5-sonnet-20241022',
  anthropic_api_key: ENV['ANTHROPIC_API_KEY'],
  test: true,
  auto_test: true,
  test_cmd: 'rspec'
)

test_executor = AiderRuby::TaskExecutor.new(test_client)

puts 'Executing test generation task...'
# result = test_executor.execute_test_generation_task(
#   "Generate comprehensive RSpec tests for the User model with edge cases",
#   ['app/models/user.rb']
# )

# Example 5: Model comparison and selection
puts "\n=== Advanced Example 5: Model Selection ==="

puts 'Available reasoning models:'
reasoning_models = AiderRuby::Models.reasoning_models
reasoning_models.each do |model|
  info = AiderRuby::Models.model_info(model)
  puts "  #{model}: #{info[:context_window]} tokens, $#{info[:cost_per_token][:input]}/1M tokens"
end

puts "\nVision-capable models:"
vision_models = AiderRuby::Models.vision_models
vision_models.each do |model|
  info = AiderRuby::Models.model_info(model)
  puts "  #{model}: #{info[:provider]}"
end

# Example 6: Configuration management
puts "\n=== Advanced Example 6: Configuration Management ==="

# Load configuration from multiple sources
AiderRuby::Config.load_from_file('config/aider.yml.example')
AiderRuby::Config.load_from_env_file('.env')

# Create client with loaded configuration
configured_client = AiderRuby.new_client

puts 'Loaded configuration:'
puts "  Model: #{configured_client.config.model}"
puts "  Dark mode: #{configured_client.config.dark_mode}"
puts "  Auto commits: #{configured_client.config.auto_commits}"
puts "  Lint: #{configured_client.config.lint}"

# Example 7: Task history management
puts "\n=== Advanced Example 7: Task History ==="

# Simulate some tasks in history
executor.instance_variable_set(:@task_history, [
                                 {
                                   id: 'task_1',
                                   type: :coding,
                                   description: 'Create User model',
                                   status: :completed,
                                   created_at: Time.now - 3600,
                                   completed_at: Time.now - 3500
                                 },
                                 {
                                   id: 'task_2',
                                   type: :refactoring,
                                   description: 'Refactor User model',
                                   status: :failed,
                                   created_at: Time.now - 1800,
                                   failed_at: Time.now - 1700,
                                   error: 'API key not found'
                                 }
                               ])

# Filter tasks
completed_tasks = executor.get_task_history(status: :completed)
puts "Completed tasks: #{completed_tasks.length}"

failed_tasks = executor.get_task_history(status: :failed)
puts "Failed tasks: #{failed_tasks.length}"

# Export history
puts 'Exporting task history...'
history_json = executor.export_history
puts "History exported (#{history_json.length} characters)"

puts "\n=== Advanced examples completed ==="
