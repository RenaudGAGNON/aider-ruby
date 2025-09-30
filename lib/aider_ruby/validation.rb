module AiderRuby
  module Validation
    class Validator
      VALID_EDIT_FORMATS = %w[whole diff diff-fenced].freeze
      VALID_REASONING_EFFORTS = %w[low medium high].freeze
      VALID_VOICE_FORMATS = %w[wav webm mp3].freeze
      VALID_LINE_ENDINGS = %w[platform lf crlf cr].freeze
      VALID_ENCODINGS = %w[utf-8 utf-16 utf-32 ascii].freeze
      
      def self.validate_model_name(model_name)
        return if model_name.nil? || model_name.empty?
        
        unless Models.supported_model?(model_name)
          ErrorHandling.handle_validation_error("Unsupported model: #{model_name}")
        end
      end
      
      def self.validate_edit_format(format)
        return if format.nil? || format.empty?
        
        unless VALID_EDIT_FORMATS.include?(format)
          ErrorHandling.handle_validation_error("Invalid edit format: #{format}. Valid formats: #{VALID_EDIT_FORMATS.join(', ')}")
        end
      end
      
      def self.validate_reasoning_effort(effort)
        return if effort.nil? || effort.empty?
        
        unless VALID_REASONING_EFFORTS.include?(effort.to_s)
          ErrorHandling.handle_validation_error("Invalid reasoning effort: #{effort}. Valid efforts: #{VALID_REASONING_EFFORTS.join(', ')}")
        end
      end
      
      def self.validate_thinking_tokens(tokens)
        return if tokens.nil? || tokens.empty?
        
        # Support formats like "1k", "8k", "1000", etc.
        token_str = tokens.to_s.downcase
        unless token_str.match?(/\A\d+[km]?\z/)
          ErrorHandling.handle_validation_error("Invalid thinking tokens format: #{tokens}. Use formats like '1k', '8k', '1000'")
        end
      end
      
      def self.validate_voice_format(format)
        return if format.nil? || format.empty?
        
        unless VALID_VOICE_FORMATS.include?(format)
          ErrorHandling.handle_validation_error("Invalid voice format: #{format}. Valid formats: #{VALID_VOICE_FORMATS.join(', ')}")
        end
      end
      
      def self.validate_line_endings(endings)
        return if endings.nil? || endings.empty?
        
        unless VALID_LINE_ENDINGS.include?(endings)
          ErrorHandling.handle_validation_error("Invalid line endings: #{endings}. Valid endings: #{VALID_LINE_ENDINGS.join(', ')}")
        end
      end
      
      def self.validate_encoding(encoding)
        return if encoding.nil? || encoding.empty?
        
        unless VALID_ENCODINGS.include?(encoding)
          ErrorHandling.handle_validation_error("Invalid encoding: #{encoding}. Valid encodings: #{VALID_ENCODINGS.join(', ')}")
        end
      end
      
      def self.validate_file_path(file_path)
        return if file_path.nil? || file_path.empty?
        
        unless File.exist?(file_path)
          ErrorHandling.handle_file_error(Errno::ENOENT.new(file_path))
        end
      end
      
      def self.validate_api_key(key, provider)
        return if key.nil? || key.empty?
        
        if key.length < 10
          ErrorHandling.handle_validation_error("Invalid #{provider} API key: too short")
        end
      end
      
      def self.validate_timeout(timeout)
        return if timeout.nil?
        
        timeout_int = timeout.to_i
        if timeout_int <= 0 || timeout_int > 3600
          ErrorHandling.handle_validation_error("Invalid timeout: #{timeout}. Must be between 1 and 3600 seconds")
        end
      end
      
      def self.validate_map_tokens(tokens)
        return if tokens.nil?
        
        tokens_int = tokens.to_i
        if tokens_int <= 0 || tokens_int > 100000
          ErrorHandling.handle_validation_error("Invalid map tokens: #{tokens}. Must be between 1 and 100000")
        end
      end
    end
  end
end
