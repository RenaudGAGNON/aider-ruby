require 'open3'
require 'json'

module AiderRuby
  module Client
    # Module for model configuration methods
    module ModelConfiguration
      def model(model_name)
        @config.model = model_name
        self
      end

      def openai_api_key(key)
        @config.openai_api_key = key
        self
      end

      def anthropic_api_key(key)
        @config.anthropic_api_key = key
        self
      end

      def reasoning_effort(effort)
        @config.reasoning_effort = effort
        self
      end

      def thinking_tokens(tokens)
        @config.thinking_tokens = tokens
        self
      end

      def use_temperature(enabled = true)
        @config.use_temperature = enabled
        self
      end

      def use_system_prompt(enabled = true)
        @config.use_system_prompt = enabled
        self
      end

      def use_repo_map(enabled = true)
        @config.use_repo_map = enabled
        self
      end

      def extra_params(params)
        @config.extra_params = params
        self
      end

      def model_settings_file(file_path)
        @config.model_settings_file = file_path
        self
      end

      def model_metadata_file(file_path)
        @config.model_metadata_file = file_path
        self
      end

      def add_alias(alias_name, model_name)
        @config.alias_settings ||= []
        @config.alias_settings << { alias: alias_name, model: model_name }
        self
      end

      def reasoning_tag(tag)
        @config.reasoning_tag = tag
        self
      end

      def weak_model_name(model_name)
        @config.weak_model_name = model_name
        self
      end

      def editor_model_name(model_name)
        @config.editor_model_name = model_name
        self
      end
    end

    # Module for output configuration methods
    module OutputConfiguration
      def dark_mode(enabled = true)
        @config.dark_mode = enabled
        self
      end

      def light_mode(enabled = true)
        @config.light_mode = enabled
        self
      end

      def pretty(enabled = true)
        @config.pretty = enabled
        self
      end

      def stream(enabled = true)
        @config.stream = enabled
        self
      end
    end

    # Module for Git configuration methods
    module GitConfiguration
      def git(enabled = true)
        @config.git = enabled
        self
      end

      def auto_commits(enabled = true)
        @config.auto_commits = enabled
        self
      end
    end

    # Module for linting and testing configuration methods
    module LintTestConfiguration
      def lint(enabled = true)
        @config.lint = enabled
        self
      end

      def auto_lint(enabled = true)
        @config.auto_lint = enabled
        self
      end

      def test(enabled = true)
        @config.test = enabled
        self
      end

      def auto_test(enabled = true)
        @config.auto_test = enabled
        self
      end
    end

    # Module for general configuration methods
    module GeneralConfiguration
      def disable_playwright(enabled = true)
        @config.disable_playwright = enabled
        self
      end

      def vim(enabled = true)
        @config.vim = enabled
        self
      end

      def chat_language(language)
        @config.chat_language = language
        self
      end

      def commit_language(language)
        @config.commit_language = language
        self
      end

      def yes_always(enabled = true)
        @config.yes_always = enabled
        self
      end

      def verbose(enabled = true)
        @config.verbose = enabled
        self
      end

      def encoding(encoding)
        @config.encoding = encoding
        self
      end

      def line_endings(endings)
        @config.line_endings = endings
        self
      end

      def suggest_shell_commands(enabled = true)
        @config.suggest_shell_commands = enabled
        self
      end

      def fancy_input(enabled = true)
        @config.fancy_input = enabled
        self
      end

      def multiline(enabled = true)
        @config.multiline = enabled
        self
      end

      def notifications(enabled = true)
        @config.notifications = enabled
        self
      end

      def notifications_command(command)
        @config.notifications_command = command
        self
      end

      def detect_urls(enabled = true)
        @config.detect_urls = enabled
        self
      end

      def editor(editor)
        @config.editor = editor
        self
      end

      def shell_completions(enabled = true)
        @config.shell_completions = enabled
        self
      end
    end

    # Module for convention and edit format methods
    module ConventionConfiguration
      # Add multiple conventions files
      def conventions_files(file_paths, validate: true)
        file_paths = Array(file_paths)
        
        if validate
          file_paths.each do |path|
            raise AiderRuby::ErrorHandling::FileError, "Conventions file not found: #{path}" unless File.exist?(path)
          end
        end
        
        # Store multiple conventions files
        @config.conventions_files ||= []
        @config.conventions_files.concat(file_paths)
        self
      end

      # Enhanced read files method with validation and filtering
      def add_read_files(files, validate: true, extensions: nil, exclude_patterns: [])
        files = Array(files)
        files = filter_files(files, extensions, exclude_patterns)
        validate_files(files) if validate
        
        @config.read_files ||= []
        @config.read_files.concat(files)
        self
      end

      # Add read files from folder with filtering
      def add_read_files_from_folder(folder_path, extensions: nil, exclude_patterns: [], validate: true)
        files = find_files_in_folder(folder_path, extensions, exclude_patterns)
        add_read_files(files, validate: validate)
      end

      # Clear all read files
      def clear_read_files
        @config.read_files = []
        self
      end

      # Get list of read files
      def read_files_list
        @config.read_files || []
      end

      def edit_format_whole(enabled = true)
        @config.edit_format_whole = enabled
        self
      end

      def edit_format_diff(enabled = true)
        @config.edit_format_diff = enabled
        self
      end

      def edit_format_diff_fenced(enabled = true)
        @config.edit_format_diff_fenced = enabled
        self
      end

      def editor_edit_format_whole(enabled = true)
        @config.editor_edit_format_whole = enabled
        self
      end

      def editor_edit_format_diff(enabled = true)
        @config.editor_edit_format_diff = enabled
        self
      end

      def editor_edit_format_diff_fenced(enabled = true)
        @config.editor_edit_format_diff_fenced = enabled
        self
      end
    end

    # Module for execution methods
    module ExecutionMethods
      def execute(message, options = {})
        args = build_command_args(options)
        args << '--message' << message

        execute_command(args)
      end

      def interactive(options = {})
        args = build_command_args(options)

        execute_command(args, interactive: true)
      end

      def execute_from_file(message_file, options = {})
        args = build_command_args(options)
        args << '--message-file' << message_file

        execute_command(args)
      end

      def apply_changes(file_path, options = {})
        args = build_command_args(options)
        args << '--apply' << file_path

        execute_command(args)
      end

      def show_repo_map(options = {})
        args = build_command_args(options)
        args << '--show-repo-map'

        execute_command(args)
      end

      def show_prompts(options = {})
        args = build_command_args(options)
        args << '--show-prompts'

        execute_command(args)
      end

      def list_models(provider = nil)
        args = ['aider']
        args << '--list-models' << provider if provider

        execute_command(args)
      end

      def check_update
        args = ['aider', '--check-update']
        execute_command(args)
      end

      def upgrade
        args = ['aider', '--upgrade']
        execute_command(args)
      end
    end

    # Main client class
    class Client
      include ModelConfiguration
      include OutputConfiguration
      include GitConfiguration
      include LintTestConfiguration
      include GeneralConfiguration
      include ConventionConfiguration
      include ExecutionMethods

      attr_reader :config, :files, :read_only_files

      def initialize(options = {}, &block)
        @config = Config::Configuration.new(options)
        @files = []
        @read_only_files = []
        
        # Apply block configuration if provided
        if block_given?
          block.call(@config)
        end
      end

      # Add files to edit (can take single file or array of files)
      def add_files(file_path)
        files_to_add = Array(file_path)
        @files.concat(files_to_add)
        self
      end

      # Add read-only files (can take single file or array of files)
      def add_read_only_file(file_path)
        files_to_add = Array(file_path)
        @read_only_files.concat(files_to_add)
        self
      end

      # Add entire folder (recursively finds all files)
      def add_folder(folder_path, extensions: nil, exclude_patterns: [])
        files = find_files_in_folder(folder_path, extensions, exclude_patterns)
        @files.concat(files)
        self
      end

      # Add folder as read-only context
      def add_read_only_folder(folder_path, extensions: nil, exclude_patterns: [])
        files = find_files_in_folder(folder_path, extensions, exclude_patterns)
        @read_only_files.concat(files)
        self
      end

      private

      def find_files_in_folder(folder_path, extensions, exclude_patterns)
        require 'find'
        files = []
        
        Find.find(folder_path) do |path|
          next if File.directory?(path)
          next unless matches_extension?(path, extensions)
          next if matches_exclude_pattern?(path, exclude_patterns)
          
          files << path
        end
        
        files
      end

      def matches_extension?(path, extensions)
        return true unless extensions
        extensions.include?(File.extname(path))
      end

      def matches_exclude_pattern?(path, exclude_patterns)
        return false if exclude_patterns.empty?
        
        exclude_patterns.any? do |pattern|
          case pattern
          when String
            path.include?(pattern)
          when Regexp
            path.match?(pattern)
          end
        end
      end

      def filter_files(files, extensions, exclude_patterns)
        files = filter_by_extensions(files, extensions) if extensions
        files = exclude_by_patterns(files, exclude_patterns) if exclude_patterns.any?
        files
      end

      def filter_by_extensions(files, extensions)
        files.select { |file| extensions.include?(File.extname(file)) }
      end

      def exclude_by_patterns(files, exclude_patterns)
        files.reject { |file| matches_exclude_pattern?(file, exclude_patterns) }
      end

      def validate_files(files)
        files.each do |file|
          unless File.exist?(file)
            raise AiderRuby::ErrorHandling::FileError, "Read file not found: #{file}"
          end
        end
      end

      def build_command_args(options = {})
        args = [Constants::AIDER_COMMAND]

        # Add config arguments
        args.concat(@config.to_aider_args)

        # Add files
        @files.each { |file| args << '--file' << file }
        @read_only_files.each { |file| args << '--read' << file }

        # Add additional options
        add_cli_options(args, options)

        args
      end

      def add_cli_options(args, options)
        options.each do |key, value|
          case key
          when :config_file
            args << '--config' << value
          when :env_file
            args << '--env-file' << value
          when :dry_run
            args << '--dry-run' if value
          when :verbose
            args << '--verbose' if value
          when :yes_always
            args << '--yes-always' if value
          end
        end
      end

      def execute_command(args, interactive: false)
        log_command(args) if @config.verbose

        if interactive
          spawn(*args)
        else
          execute_non_interactive(args)
        end
      end

      def execute_non_interactive(args)
        stdout, stderr, status = Open3.capture3(*args)
        
        unless status.success?
          raise AiderRuby::ErrorHandling::ExecutionError,
            "Command failed with exit code #{status.exitstatus}: #{stderr}"
        end
        
        stdout
      rescue Errno::ENOENT => e
        AiderRuby::ErrorHandling.handle_execution_error(e)
      rescue => e
        raise AiderRuby::ErrorHandling::ExecutionError,
          "Unexpected error executing command: #{e.message}"
      end

      def log_command(args)
        puts "Executing: #{args.join(' ')}"
      end
    end
  end
end
