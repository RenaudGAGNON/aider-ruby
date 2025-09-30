# AiderRuby Architecture

## Overview

AiderRuby uses a modular architecture to organize code in a clear and maintainable way. The gem is structured into specialized modules that manage different aspects of functionality.

## Module Structure

### 1. Main Module (`AiderRuby`)

The main module provides the public interface of the gem:

```ruby
module AiderRuby
  class Error < StandardError; end
  
  def self.new_client(options = {})
    Client::Client.new(options)
  end
  
  def self.configure(&block)
    Config::Configuration.configure(&block)
  end
  
  def self.version
    VERSION
  end
  
  # Aliases for compatibility
  Config = Config::Configuration
  Client = Client::Client
end
```

### 2. Configuration Module (`AiderRuby::Config`)

The configuration module is organized into specialized sub-modules:

#### Configuration Modules:
- **`ModelOptions`**: LLM model options
- **`CacheOptions`**: Cache options
- **`RepomapOptions`**: Repository map options
- **`HistoryOptions`**: History options
- **`OutputOptions`**: Output options
- **`GitOptions`**: Git options
- **`LintTestOptions`**: Linting and testing options
- **`AnalyticsOptions`**: Analytics options
- **`VoiceOptions`**: Voice options
- **`GeneralOptions`**: General options
- **`ConventionOptions`**: Convention and edit format options

#### Main Class: `AiderRuby::Config::Configuration`

```ruby
class Configuration
  include ModelOptions
  include CacheOptions
  include RepomapOptions
  # ... other modules
  
  def initialize(options = {})
    set_defaults
    apply_options(options)
  end
  
  def to_aider_args
    args = []
    args.concat(model_args)
    args.concat(cache_args)
    # ... other argument categories
    args
  end
end
```

### 3. Client Module (`AiderRuby::Client`)

The client module is organized into feature modules:

#### Configuration Modules:
- **`ModelConfiguration`**: Model configuration
- **`OutputConfiguration`**: Output configuration
- **`GitConfiguration`**: Git configuration
- **`LintTestConfiguration`**: Linting and testing configuration
- **`ConventionConfiguration`**: Convention configuration

#### Execution Module:
- **`ExecutionMethods`**: Command execution methods

#### Main Class: `AiderRuby::Client::Client`

```ruby
class Client
  include ModelConfiguration
  include OutputConfiguration
  include GitConfiguration
  include LintTestConfiguration
  include ConventionConfiguration
  include ExecutionMethods
  
  attr_reader :config, :files, :read_only_files
  
  def initialize(options = {})
    @config = Config::Configuration.new(options)
    @files = []
    @read_only_files = []
  end
end
```

### 4. Error Handling Module (`AiderRuby::ErrorHandling`)

Provides structured error handling:

```ruby
module ErrorHandling
  class ConfigurationError < Error; end
  class ModelError < Error; end
  class ExecutionError < Error; end
  class FileError < Error; end
  class ValidationError < Error; end
  
  def self.handle_configuration_error(error)
    # Specialized configuration error handling
  end
  
  def self.handle_model_error(error)
    # Specialized model error handling
  end
  
  # ... other handling methods
end
```

### 5. Validation Module (`AiderRuby::Validation`)

Provides robust validations:

```ruby
module Validation
  class Validator
    VALID_EDIT_FORMATS = %w[whole diff diff-fenced].freeze
    VALID_REASONING_EFFORTS = %w[low medium high].freeze
    # ... other constants
    
    def self.validate_model_name(model_name)
      # Model name validation
    end
    
    def self.validate_edit_format(format)
      # Edit format validation
    end
    
    # ... other validation methods
  end
end
```

## Benefits of This Architecture

### 1. **Separation of Concerns**
- Each module has a clear and defined responsibility
- Facilitates maintenance and testing

### 2. **Reusability**
- Modules can be used independently
- Facilitates feature extension

### 3. **Readability**
- Code is organized logically
- Facilitates understanding for new developers

### 4. **Maintainability**
- Modifications are isolated in specific modules
- Reduces regression risks

### 5. **Testability**
- Each module can be tested independently
- Facilitates unit and integration testing

## Using the Architecture

### Modular Configuration

```ruby
# Using configuration modules
client = AiderRuby.new_client

# Model configuration
client.model('gpt-4o')
client.reasoning_effort('high')
client.thinking_tokens('8k')

# Output configuration
client.dark_mode(true)
client.pretty(true)

# Git configuration
client.git(true)
client.auto_commits(true)

# Convention configuration
client.conventions_file('CONVENTIONS.md')
client.edit_format_diff(true)
```

### Robust Error Handling

```ruby
begin
  client = AiderRuby.new_client(model: 'invalid-model')
rescue AiderRuby::ErrorHandling::ModelError => e
  puts "Model error: #{e.message}"
rescue AiderRuby::ErrorHandling::ConfigurationError => e
  puts "Configuration error: #{e.message}"
end
```

### Parameter Validation

```ruby
# Validation is automatic during configuration
client.edit_format_diff(true)  # ✅ Valid
client.edit_format('invalid')  # ❌ Raises ValidationError
```

## Extensibility

This architecture facilitates adding new features:

1. **New Configuration Modules**: Add new modules for new option categories
2. **New Validation Methods**: Extend the validation module
3. **New Error Types**: Add new specialized error types
4. **New Client Features**: Create new feature modules

## Compatibility

The architecture maintains compatibility with the existing API through aliases:

```ruby
# Old API (still supported)
AiderRuby::Config.new
AiderRuby::Client.new

# New API (recommended)
AiderRuby::Config::Configuration.new
AiderRuby::Client::Client.new
```

This architecture ensures that the gem remains easy to use while being robust and maintainable.