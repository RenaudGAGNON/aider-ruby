require 'yaml'
require 'json'

module AiderRuby
  module Config
    # Module to manage model options
    module ModelOptions
      attr_accessor :model, :openai_api_key, :anthropic_api_key, :openai_api_base,
                    :openai_api_type, :openai_api_version, :openai_api_deployment_id,
                    :openai_organization_id, :reasoning_effort, :thinking_tokens,
                    :verify_ssl, :timeout, :edit_format, :architect, :auto_accept_architect,
                    :weak_model, :editor_model, :editor_edit_format, :show_model_warnings,
                    :check_model_accepts_settings, :max_chat_history_tokens

      # Advanced model parameters
      attr_accessor :use_temperature, :use_system_prompt, :use_repo_map, :extra_params,
                    :model_settings_file, :model_metadata_file, :alias_settings,
                    :reasoning_tag, :weak_model_name, :editor_model_name
    end

    # Module to manage cache options
    module CacheOptions
      attr_accessor :cache_prompts, :cache_keepalive_pings
    end

    # Module to manage repomap options
    module RepomapOptions
      attr_accessor :map_tokens, :map_refresh, :map_multiplier_no_files
    end

    # Module to manage history options
    module HistoryOptions
      attr_accessor :input_history_file, :chat_history_file, :restore_chat_history,
                    :llm_history_file
    end

    # Module to manage output options
    module OutputOptions
      attr_accessor :dark_mode, :light_mode, :pretty, :stream, :user_input_color,
                    :tool_output_color, :tool_error_color, :tool_warning_color,
                    :assistant_output_color, :completion_menu_color, :completion_menu_bg_color,
                    :completion_menu_current_color, :completion_menu_current_bg_color,
                    :code_theme, :show_diffs
    end

    # Module to manage Git options
    module GitOptions
      attr_accessor :git, :gitignore, :add_gitignore_files, :aiderignore, :subtree_only,
                    :auto_commits, :dirty_commits, :attribute_author, :attribute_committer,
                    :attribute_commit_message_author, :attribute_commit_message_committer,
                    :attribute_co_authored_by, :git_commit_verify, :commit, :commit_prompt,
                    :dry_run, :skip_sanity_check_repo, :watch_files
    end

    # Module to manage linting and testing options
    module LintTestOptions
      attr_accessor :lint, :lint_cmd, :auto_lint, :test_cmd, :auto_test, :test
    end

    # Module to manage analytics options
    module AnalyticsOptions
      attr_accessor :analytics, :analytics_log, :analytics_disable, :analytics_posthog_host,
                    :analytics_posthog_project_api_key
    end

    # Module to manage voice options
    module VoiceOptions
      attr_accessor :voice_format, :voice_language, :voice_input_device
    end

    # Module to manage general options
    module GeneralOptions
      attr_accessor :disable_playwright, :vim, :chat_language, :commit_language,
                    :yes_always, :verbose, :encoding, :line_endings, :suggest_shell_commands,
                    :fancy_input, :multiline, :notifications, :notifications_command,
                    :detect_urls, :editor, :shell_completions
    end

    # Module to manage conventions and edit formats
    module ConventionOptions
      attr_accessor :conventions_files, :read_files
      
      # Edit formats
      attr_accessor :edit_format_whole, :edit_format_diff, :edit_format_diff_fenced,
                    :editor_edit_format_whole, :editor_edit_format_diff, :editor_edit_format_diff_fenced
    end

    # Main configuration class
    class Configuration
      include ModelOptions
      include CacheOptions
      include RepomapOptions
      include HistoryOptions
      include OutputOptions
      include GitOptions
      include LintTestOptions
      include AnalyticsOptions
      include VoiceOptions
      include GeneralOptions
      include ConventionOptions

      class << self
        attr_accessor :config_file, :env_file

        def configure(&block)
          instance_eval(&block) if block_given?
        end

        def load_from_file(file_path)
          return unless File.exist?(file_path)

          config = parse_config_file(file_path)
          apply_config(config)
        end

        def load_from_env_file(file_path = '.env')
          return unless File.exist?(file_path)

          load_env_variables(file_path)
        end

        private

        def parse_config_file(file_path)
          case File.extname(file_path)
          when '.yml', '.yaml'
            YAML.load_file(file_path)
          when '.json'
            JSON.parse(File.read(file_path))
          else
            raise Error, "Unsupported config file format: #{File.extname(file_path)}"
          end
        end

        def load_env_variables(file_path)
          File.readlines(file_path).each do |line|
            next if line.strip.empty? || line.start_with?('#')

            key, value = line.strip.split('=', 2)
            next unless key && value

            env_key = "AIDER_#{key.upcase}"
            ENV[env_key] = value
          end
        end

        def apply_config(config)
          config.each do |key, value|
            method_name = "#{key}="
            send(method_name, value) if respond_to?(method_name)
          end
        end
      end

      def initialize(options = {})
        set_defaults
        apply_options(options)
      end

      def to_aider_args
        args = []

        args.concat(model_args)
        args.concat(cache_args)
        args.concat(repomap_args)
        args.concat(history_args)
        args.concat(output_args)
        args.concat(git_args)
        args.concat(lint_test_args)
        args.concat(analytics_args)
        args.concat(voice_args)
        args.concat(general_args)
        args.concat(convention_args)

        args
      end

      private

      def apply_options(options)
        options.each { |key, value| send("#{key}=", value) if respond_to?("#{key}=") }
      end

      def set_defaults
        @encoding = 'utf-8'
        @line_endings = 'platform'
        @suggest_shell_commands = true
        @fancy_input = true
        @detect_urls = true
        @voice_format = 'wav'
        @voice_language = 'en'
      end

      # Methods to generate arguments by category
      def model_args
        args = []

        args << '--model' << model if model
        args << '--openai-api-key' << openai_api_key if openai_api_key
        args << '--anthropic-api-key' << anthropic_api_key if anthropic_api_key
        args << '--openai-api-base' << openai_api_base if openai_api_base
        args << '--openai-api-type' << openai_api_type if openai_api_type
        args << '--openai-api-version' << openai_api_version if openai_api_version
        args << '--openai-api-deployment-id' << openai_api_deployment_id if openai_api_deployment_id
        args << '--openai-organization-id' << openai_organization_id if openai_organization_id
        args << '--reasoning-effort' << reasoning_effort.to_s if reasoning_effort
        args << '--thinking-tokens' << thinking_tokens.to_s if thinking_tokens
        args << '--verify-ssl' if verify_ssl
        args << '--timeout' << timeout.to_s if timeout
        args << '--edit-format' << edit_format if edit_format
        args << '--architect' if architect
        args << '--auto-accept-architect' if auto_accept_architect
        args << '--weak-model' << weak_model if weak_model
        args << '--editor-model' << editor_model if editor_model
        args << '--editor-edit-format' << editor_edit_format if editor_edit_format
        args << '--show-model-warnings' if show_model_warnings
        args << '--check-model-accepts-settings' if check_model_accepts_settings
        args << '--max-chat-history-tokens' << max_chat_history_tokens.to_s if max_chat_history_tokens

        # Advanced parameters
        args << '--model-settings-file' << model_settings_file if model_settings_file
        args << '--model-metadata-file' << model_metadata_file if model_metadata_file
        (alias_settings || []).each do |alias_setting|
          args << '--alias' << "#{alias_setting[:alias]}:#{alias_setting[:model]}"
        end

        args
      end

      def cache_args
        args = []
        args << '--cache-prompts' if cache_prompts
        args << '--cache-keepalive-pings' << cache_keepalive_pings.to_s if cache_keepalive_pings
        args
      end

      def repomap_args
        args = []
        args << '--map-tokens' << map_tokens.to_s if map_tokens
        args << '--map-refresh' << map_refresh.to_s if map_refresh
        args << '--map-multiplier-no-files' << map_multiplier_no_files.to_s if map_multiplier_no_files
        args
      end

      def history_args
        args = []
        args << '--input-history-file' << input_history_file if input_history_file
        args << '--chat-history-file' << chat_history_file if chat_history_file
        args << '--restore-chat-history' if restore_chat_history
        args << '--llm-history-file' << llm_history_file if llm_history_file
        args
      end

      def output_args
        args = []
        args << '--dark-mode' if dark_mode
        args << '--light-mode' if light_mode
        args << '--pretty' if pretty
        args << '--stream' if stream
        args << '--user-input-color' << user_input_color if user_input_color
        args << '--tool-output-color' << tool_output_color if tool_output_color
        args << '--tool-error-color' << tool_error_color if tool_error_color
        args << '--tool-warning-color' << tool_warning_color if tool_warning_color
        args << '--assistant-output-color' << assistant_output_color if assistant_output_color
        args << '--completion-menu-color' << completion_menu_color if completion_menu_color
        args << '--completion-menu-bg-color' << completion_menu_bg_color if completion_menu_bg_color
        args << '--completion-menu-current-color' << completion_menu_current_color if completion_menu_current_color
        if completion_menu_current_bg_color
          args << '--completion-menu-current-bg-color' << completion_menu_current_bg_color
        end
        args << '--code-theme' << code_theme if code_theme
        args << '--show-diffs' if show_diffs
        args
      end

      def git_args
        args = []
        args << '--git' if git
        args << '--gitignore' if gitignore
        args << '--add-gitignore-files' if add_gitignore_files
        args << '--aiderignore' << aiderignore if aiderignore
        args << '--subtree-only' if subtree_only
        args << '--auto-commits' if auto_commits
        args << '--dirty-commits' if dirty_commits
        args << '--attribute-author' if attribute_author
        args << '--attribute-committer' if attribute_committer
        args << '--attribute-commit-message-author' if attribute_commit_message_author
        args << '--attribute-commit-message-committer' if attribute_commit_message_committer
        args << '--attribute-co-authored-by' if attribute_co_authored_by
        args << '--git-commit-verify' if git_commit_verify
        args << '--commit' if commit
        args << '--commit-prompt' << commit_prompt if commit_prompt
        args << '--dry-run' if dry_run
        args << '--skip-sanity-check-repo' if skip_sanity_check_repo
        args << '--watch-files' if watch_files
        args
      end

      def lint_test_args
        args = []
        args << '--lint' if lint
        args << '--lint-cmd' << lint_cmd if lint_cmd
        args << '--auto-lint' if auto_lint
        args << '--test-cmd' << test_cmd if test_cmd
        args << '--auto-test' if auto_test
        args << '--test' if test
        args
      end

      def analytics_args
        args = []
        args << '--analytics' if analytics
        args << '--analytics-log' << analytics_log if analytics_log
        args << '--analytics-disable' if analytics_disable
        args << '--analytics-posthog-host' << analytics_posthog_host if analytics_posthog_host
        if analytics_posthog_project_api_key
          args << '--analytics-posthog-project-api-key' << analytics_posthog_project_api_key
        end
        args
      end

      def voice_args
        args = []
        args << '--voice-format' << voice_format if voice_format
        args << '--voice-language' << voice_language if voice_language
        args << '--voice-input-device' << voice_input_device if voice_input_device
        args
      end

      def general_args
        args = []
        args << '--disable-playwright' if disable_playwright
        args << '--vim' if vim
        args << '--chat-language' << chat_language if chat_language
        args << '--commit-language' << commit_language if commit_language
        args << '--yes-always' if yes_always
        args << '--verbose' if verbose
        args << '--encoding' << encoding if encoding
        args << '--line-endings' << line_endings if line_endings
        args << '--suggest-shell-commands' if suggest_shell_commands
        args << '--fancy-input' if fancy_input
        args << '--multiline' if multiline
        args << '--notifications' if notifications
        args << '--notifications-command' << notifications_command if notifications_command
        args << '--detect-urls' if detect_urls
        args << '--editor' << editor if editor
        args
      end

      def convention_args
        args = []
        
        # Multiple conventions files
        (conventions_files || []).each { |file| args << '--read' << file }
        
        # Read files
        (read_files || []).each { |file| args << '--read' << file }

        # Edit formats
        args << '--edit-format' << 'whole' if edit_format_whole
        args << '--edit-format' << 'diff' if edit_format_diff
        args << '--edit-format' << 'diff-fenced' if edit_format_diff_fenced
        args << '--editor-edit-format' << 'whole' if editor_edit_format_whole
        args << '--editor-edit-format' << 'diff' if editor_edit_format_diff
        args << '--editor-edit-format' << 'diff-fenced' if editor_edit_format_diff_fenced

        args
      end
    end
  end
end
