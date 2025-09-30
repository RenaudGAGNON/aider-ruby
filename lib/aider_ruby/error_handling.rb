module AiderRuby
  module ErrorHandling
    class ConfigurationError < AiderRuby::Error; end
    class ModelError < AiderRuby::Error; end
    class ExecutionError < AiderRuby::Error; end
    class FileError < AiderRuby::Error; end
    class ValidationError < AiderRuby::Error; end
    
    def self.handle_configuration_error(error)
      case error
      when Errno::ENOENT
        raise ConfigurationError, "Configuration file not found: #{error.message}"
      when Psych::SyntaxError
        raise ConfigurationError, "Invalid YAML syntax in configuration file: #{error.message}"
      when JSON::ParserError
        raise ConfigurationError, "Invalid JSON syntax in configuration file: #{error.message}"
      else
        raise ConfigurationError, "Configuration error: #{error.message}"
      end
    end
    
    def self.handle_model_error(error)
      case error
      when ArgumentError
        raise ModelError, "Invalid model configuration: #{error.message}"
      else
        raise ModelError, "Model error: #{error.message}"
      end
    end
    
    def self.handle_execution_error(error)
      case error
      when Errno::ENOENT
        raise ExecutionError, "Aider command not found. Please install aider first."
      when Errno::EACCES
        raise ExecutionError, "Permission denied when executing aider command"
      else
        raise ExecutionError, "Execution error: #{error.message}"
      end
    end
    
    def self.handle_file_error(error)
      case error
      when Errno::ENOENT
        raise FileError, "File not found: #{error.message}"
      when Errno::EACCES
        raise FileError, "Permission denied accessing file: #{error.message}"
      else
        raise FileError, "File error: #{error.message}"
      end
    end
    
    def self.handle_validation_error(message)
      raise ValidationError, message
    end
  end
end
