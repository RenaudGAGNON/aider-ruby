# AiderRuby

A Ruby gem that serves as a wrapper for [aider](https://aider.chat), enabling LLM configuration and execution of AI-assisted programming tasks.

## 🏗️ Architecture

AiderRuby uses a modular architecture to organize code in a clear and maintainable way:

- **Specialized configuration modules**: Each option category has its own module
- **Robust error handling**: Specialized error types with contextual handling
- **Integrated validation**: Automatic parameter validation
- **Fluid API**: Chainable methods for intuitive configuration
- **Compatibility**: Maintains existing API with aliases

See [ARCHITECTURE.md](ARCHITECTURE.md) for more details on the architecture.

## Installation

```bash
gem install aider-ruby
```

Or add it to your Gemfile:

```ruby
gem 'aider-ruby'
```

## Usage

### Command Line Interface

```bash
# Execute aider with a message
aider-ruby execute "Create a function to calculate factorial"

# Interactive mode
aider-ruby interactive

# Use a specific model
aider-ruby execute "Refactor this code" --model claude-3-5-sonnet-20241022

# Add files
aider-ruby execute "Improve this function" --files app/models/user.rb

# Verbose mode
aider-ruby execute "Debug this issue" --verbose

# List available models
aider-ruby models

# Model information
aider-ruby model_info gpt-4o

# Recommended models
aider-ruby recommended

# Load coding conventions
aider-ruby conventions CONVENTIONS.md

# Set edit format
aider-ruby edit_format diff

# Show reasoning settings
aider-ruby reasoning_settings

# Execute with advanced parameters
aider-ruby execute "Task" --reasoning-effort high --thinking-tokens 8k --edit-format diff-fenced
```

### Programmatic Usage

```ruby
require 'aider_ruby'

# Create a client
client = AiderRuby.new_client(
  model: 'claude-3-5-sonnet-20241022',
  openai_api_key: 'your-key',
  anthropic_api_key: 'your-key'
)

# Add files
client.add_files('app/models/user.rb')
client.add_files(['app/models/user.rb', 'app/models/post.rb'])  # Multiple files
client.add_read_only_file('README.md')
client.add_read_only_file(['docs/api.md', 'docs/guide.md'])  # Multiple read-only files

# Add entire folders
client.add_folder('app/models', extensions: ['.rb'])  # Only Ruby files
client.add_read_only_folder('docs', exclude_patterns: ['temp/', /\.tmp$/])  # Exclude patterns

# Configure coding conventions
client.conventions_files(['CONVENTIONS.md', 'STYLE_GUIDE.md'])  # Multiple files
client.add_read_files(['docs/guidelines.md', 'examples/patterns.rb'])  # Basic usage
client.add_read_files(['docs/'], extensions: ['.md'], exclude_patterns: ['temp/'])  # With filtering

# Configure edit formats
client.edit_format_diff(true)
client.editor_edit_format_diff_fenced(true)

# Advanced model configuration
client.use_temperature(true)
client.use_system_prompt(true)
client.use_repo_map(true)
client.reasoning_effort('high')
client.thinking_tokens('8k')

# Add model aliases
client.add_alias('sonnet', 'claude-3-5-sonnet-20241022')
client.add_alias('fast', 'claude-3-5-haiku-20241022')

# Execute a task
result = client.execute("Create tests for this class")
puts result

# Interactive mode
client.interactive

# Advanced configuration
client
  .model('gpt-4o')
  .add_files('app/models/user.rb')
  .dark_mode(true)
  .auto_commits(true)
  .lint(true)
  .execute("Refactor this code")
```

### Error Handling

AiderRuby provides robust error handling with specialized error types:

```ruby
begin
  client = AiderRuby.new_client(model: 'invalid-model')
rescue AiderRuby::ErrorHandling::ModelError => e
  puts "Model error: #{e.message}"
rescue AiderRuby::ErrorHandling::ConfigurationError => e
  puts "Configuration error: #{e.message}"
rescue AiderRuby::ErrorHandling::ExecutionError => e
  puts "Execution error: #{e.message}"
rescue AiderRuby::ErrorHandling::FileError => e
  puts "File error: #{e.message}"
rescue AiderRuby::ErrorHandling::ValidationError => e
  puts "Validation error: #{e.message}"
end
```

### Parameter Validation

Validation is automatic during configuration:

```ruby
# ✅ Valid formats
client.edit_format_diff(true)
client.reasoning_effort('high')
client.thinking_tokens('8k')

# ❌ Invalid formats (raise ValidationError)
client.edit_format('invalid')
client.reasoning_effort('invalid')
client.thinking_tokens('invalid')
```

### File Management

AiderRuby provides flexible file management options:

#### Adding Files for Editing
```ruby
# Single file
client.add_files('app/models/user.rb')

# Multiple files
client.add_files(['app/models/user.rb', 'app/models/post.rb'])

# Entire folder (with filters)
client.add_folder('app/models', 
  extensions: ['.rb'],  # Only Ruby files
  exclude_patterns: ['spec/', /_test\.rb$/]  # Exclude test files
)
```

#### Adding Files for Context (Read-Only)
```ruby
# Single read-only file
client.add_read_only_file('README.md')

# Multiple read-only files
client.add_read_only_file(['docs/api.md', 'docs/guide.md'])

# Entire folder as context
client.add_read_only_folder('docs', 
  extensions: ['.md', '.txt'],
  exclude_patterns: ['temp/', /\.tmp$/]
)

# Using conventions (alternative method)
client.add_read_files(['docs/guidelines.md', 'examples/patterns.rb'])
```

#### Key Differences
- **`add_files()`**: Files that aider can **modify/edit** (uses `--file` flag)
- **`add_read_only_file()`**: Files for **context only** (uses `--read` flag)
- **`add_read_files()`**: Alternative method for read-only files (stored in config)
- **`add_folder()`**: Recursively adds all files in a folder for editing
- **`add_read_only_folder()`**: Recursively adds all files in a folder as context

### Enhanced Convention Management

AiderRuby provides advanced convention management with validation and filtering:

#### Single Convention File
```ruby
# Basic usage with validation (default)
client.conventions_files(['CONVENTIONS.md'])

# Skip validation for non-existent files
client.conventions_files(['CONVENTIONS.md'], validate: false)
```

#### Multiple Convention Files
```ruby
# Add multiple convention files
client.conventions_files(['CONVENTIONS.md', 'STYLE_GUIDE.md', 'PATTERNS.md'])

# With validation disabled
client.conventions_files(['CONVENTIONS.md', 'STYLE_GUIDE.md'], validate: false)
```

#### Enhanced Read Files Management
```ruby
# Basic usage
client.add_read_files(['docs/guidelines.md', 'examples/patterns.rb'])

# With filtering by extensions
client.add_read_files(['docs/'], extensions: ['.md', '.txt'])

# With exclusion patterns
client.add_read_files(['docs/'], 
  extensions: ['.md'], 
  exclude_patterns: ['temp/', /\.tmp$/, 'draft/']
)

# Skip validation
client.add_read_files(['docs/'], validate: false)

# Add from entire folder with filtering
client.add_read_files_from_folder('docs', 
  extensions: ['.md', '.txt'],
  exclude_patterns: ['temp/', /\.tmp$/]
)

# Clear all read files
client.clear_read_files

# Get list of read files
files = client.read_files_list
```

#### Key Differences
- **`conventions_files()`**: Convention files with validation (single or multiple)
- **`add_read_files()`**: Enhanced method with filtering and validation
- **`add_read_files_from_folder()`**: Add files from folder with filtering
- **`clear_read_files()`**: Clear all read files
- **`read_files_list()`**: Get current list of read files

### Complete In-Code Configuration

AiderRuby allows complete configuration without external files or environment variables:

```ruby
# Complete configuration in code
client = AiderRuby.new_client(
  # Model configuration
  model: 'claude-3-5-sonnet-20241022',
  anthropic_api_key: 'sk-ant-your-key',
  reasoning_effort: 'high',
  thinking_tokens: '8k',
  
  # Output configuration
  dark_mode: true,
  pretty: true,
  stream: true,
  show_diffs: true,
  
  # Git configuration
  git: true,
  auto_commits: true,
  dirty_commits: false,
  
  # Linting and testing
  lint: true,
  auto_lint: true,
  test: true,
  auto_test: true,
  
  # General settings
  verbose: true,
  encoding: 'utf-8',
  suggest_shell_commands: true,
  fancy_input: true,
  detect_urls: true,
  
  # Conventions and files
  conventions_files: ['CONVENTIONS.md'],
  read_files: ['README.md'],
  
  # Edit formats
  edit_format_diff: true
)

# Add files and execute
client
  .add_files(['app/models/user.rb', 'app/models/post.rb'])
  .add_read_only_file('docs/api.md')
  .execute("Refactor this code")
```

### Configuration with Files

```ruby
# YAML Configuration
AiderRuby.configure do
  model 'claude-3-5-sonnet-20241022'
  openai_api_key ENV['OPENAI_API_KEY']
  anthropic_api_key ENV['ANTHROPIC_API_KEY']
  dark_mode true
  auto_commits true
  lint true
  auto_lint true
end

# Load from file
AiderRuby::Config.load_from_file('config/aider.yml')
AiderRuby::Config.load_from_env_file('.env')
```

### Specialized Task Execution

```ruby
client = AiderRuby.new_client
executor = AiderRuby::TaskExecutor.new(client)

# Coding task
executor.execute_coding_task(
  "Implement a REST API",
  ['app/controllers/api_controller.rb']
)

# Refactoring task
executor.execute_refactoring_task(
  "Refactor this class to follow SOLID principles",
  ['app/models/user.rb']
)

# Debugging task
executor.execute_debugging_task(
  "Fix errors in this function",
  ['app/services/payment_service.rb']
)

# Documentation task
executor.execute_documentation_task(
  "Create API documentation",
  ['app/controllers/api_controller.rb']
)

# Test generation
executor.execute_test_generation_task(
  "Generate comprehensive unit tests",
  ['app/models/user.rb']
)

# Multi-step task
steps = [
  "Analyze existing code",
  "Identify possible improvements",
  "Implement changes",
  "Create tests"
]
executor.execute_multi_step_task(steps, ['app/models/user.rb'])
```

### Model Management

```ruby
# List available models
AiderRuby::Models.list_models
AiderRuby::Models.list_models(:openai)

# Check if a model is supported
AiderRuby::Models.supported_model?('gpt-4o')

# Get model provider
AiderRuby::Models.provider_for_model('gpt-4o')

# Check capabilities
AiderRuby::Models.is_reasoning_model?('o1-preview')
AiderRuby::Models.has_vision?('gpt-4o')

# Detailed information
info = AiderRuby::Models.model_info('gpt-4o')
puts "Context: #{info[:context_window]} tokens"
puts "Cost: $#{info[:cost_per_token][:input]} per 1M tokens"

# Recommended models
AiderRuby::Models.recommended_models
```

## Configuration

### Environment Variables

```bash
export OPENAI_API_KEY="your-openai-key"
export ANTHROPIC_API_KEY="your-anthropic-key"
export AIDER_MODEL="claude-3-5-sonnet-20241022"
export AIDER_DARK_MODE="true"
export AIDER_AUTO_COMMITS="true"
```

### YAML Configuration File

```yaml
# config/aider.yml
model: claude-3-5-sonnet-20241022
openai_api_key: ${OPENAI_API_KEY}
anthropic_api_key: ${ANTHROPIC_API_KEY}
dark_mode: true
light_mode: false
pretty: true
stream: true
git: true
auto_commits: true
dirty_commits: false
lint: true
auto_lint: true
test: true
auto_test: true
verbose: false
encoding: utf-8
line_endings: platform
suggest_shell_commands: true
fancy_input: true
multiline: false
notifications: false
detect_urls: true
voice_format: wav
voice_language: en
```

### .env File

```bash
# .env
OPENAI_API_KEY=your-openai-key
ANTHROPIC_API_KEY=your-anthropic-key
AIDER_MODEL=claude-3-5-sonnet-20241022
AIDER_DARK_MODE=true
AIDER_AUTO_COMMITS=true
```

## Features

### Supported Models

- **OpenAI**: gpt-4o, gpt-4o-mini, gpt-4-turbo, gpt-4, gpt-3.5-turbo, o1-preview, o1-mini
- **Anthropic**: claude-3-5-sonnet, claude-3-5-haiku, claude-3-opus, claude-3-sonnet, claude-3-haiku
- **Google**: gemini-1.5-pro, gemini-1.5-flash, gemini-pro
- **GROQ**: llama-3.1-70b-versatile, llama-3.1-8b-instant, mixtral-8x7b-32768, gemma-7b-it
- **DeepSeek**: deepseek-chat, deepseek-coder
- **xAI**: grok-beta
- **Cohere**: command-r-plus, command-r, command-light

### Task Types

- **Coding**: Development of new features
- **Refactoring**: Improvement of existing code
- **Debugging**: Problem resolution
- **Documentation**: Documentation creation
- **Test Generation**: Test generation
- **Multi-step**: Complex multi-step tasks

### Configuration Options

- Model and API key configuration
- Reasoning parameters (reasoning_effort, thinking_tokens)
- Output options (dark_mode, pretty, stream)
- Git integration (auto_commits, dirty_commits)
- Automatic linting and testing
- Voice parameters
- Advanced model configuration
- **Coding conventions**: Support for convention files
- **Edit formats**: whole, diff, diff-fenced
- **Advanced parameters**: temperature, system prompt, repo map
- **Model aliases**: Custom alias definitions
- **Model metadata**: Capability and cost configuration

## Development

### Install Dependencies

```bash
bundle install
```

### Tests

```bash
bundle exec rspec
```

### Linting

```bash
bundle exec rubocop
```

### Build Gem

```bash
gem build aider-ruby.gemspec
gem install ./aider-ruby-0.1.0.gem
```

## License

MIT License

## Contributing

Contributions are welcome! Feel free to open an issue or pull request.

## Useful Links

- [Aider Documentation](https://aider.chat/docs/)
- [Configuration Options](https://aider.chat/docs/config/options.html)
- [Reasoning Models](https://aider.chat/docs/config/reasoning.html)
- [Advanced Model Settings](https://aider.chat/docs/config/adv-model-settings.html)
- [Scripting with Aider](https://aider.chat/docs/scripting.html)
