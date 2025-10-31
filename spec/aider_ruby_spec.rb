require 'spec_helper'
require 'aider_ruby'
require 'tempfile'

RSpec.describe AiderRuby do
  describe '.new_client' do
    it 'creates a new client with default options' do
      client = AiderRuby.new_client
      expect(client).to be_a(AiderRuby::Client::Client)
      expect(client.config).to be_a(AiderRuby::Config::Configuration)
    end

    it 'creates a client with custom options' do
      client = AiderRuby.new_client(model: 'gpt-4o', verbose: true)
      expect(client.config.model).to eq('gpt-4o')
      expect(client.config.verbose).to be true
    end
  end

  describe '.version' do
    it 'returns the version' do
      expect(AiderRuby.version).to eq('0.1.0')
    end
  end
end

RSpec.describe AiderRuby::Config::Configuration do
  let(:config) { AiderRuby::Config::Configuration.new }

  describe '#initialize' do
    it 'sets default values' do
      expect(config.encoding).to eq('utf-8')
      expect(config.line_endings).to eq('platform')
      expect(config.suggest_shell_commands).to be true
      expect(config.fancy_input).to be true
      expect(config.detect_urls).to be true
      expect(config.voice_format).to eq('wav')
      expect(config.voice_language).to eq('en')
    end

    it 'accepts custom options' do
      config = AiderRuby::Config::Configuration.new(model: 'gpt-4o', verbose: true)
      expect(config.model).to eq('gpt-4o')
      expect(config.verbose).to be true
    end
  end

  describe '#to_aider_args' do
    it 'converts config to aider command arguments' do
      config.model = 'gpt-4o'
      config.openai_api_key = 'test-key'
      config.dark_mode = true
      config.verbose = true

      args = config.to_aider_args
      expect(args).to include('--model', 'gpt-4o')
      expect(args).to include('--openai-api-key', 'test-key')
      expect(args).to include('--dark-mode')
      expect(args).to include('--verbose')
    end

    it 'handles nil values correctly' do
      args = config.to_aider_args
      expect(args).not_to include('--model')
      expect(args).not_to include('--openai-api-key')
    end
  end
end

RSpec.describe AiderRuby::Client::Client do
  let(:client) { AiderRuby::Client::Client.new }

  describe '#add_files' do
    it 'adds a file to the files list' do
      client.add_files('test.rb')
      expect(client.files).to include('test.rb')
    end

    it 'returns self for chaining' do
      result = client.add_files('test.rb')
      expect(result).to eq(client)
    end

    it 'adds multiple files' do
      client.add_files(['test1.rb', 'test2.rb'])
      expect(client.files).to include('test1.rb', 'test2.rb')
    end
  end

  describe '#add_read_only_file' do
    it 'adds a read-only file to the read_only_files list' do
      client.add_read_only_file('README.md')
      expect(client.read_only_files).to include('README.md')
    end

    it 'returns self for chaining' do
      result = client.add_read_only_file('README.md')
      expect(result).to eq(client)
    end

    it 'adds multiple read-only files' do
      client.add_read_only_file(['README.md', 'LICENSE'])
      expect(client.read_only_files).to include('README.md', 'LICENSE')
    end
  end

  describe '#model' do
    it 'sets the model' do
      client.model('gpt-4o')
      expect(client.config.model).to eq('gpt-4o')
    end

    it 'returns self for chaining' do
      result = client.model('gpt-4o')
      expect(result).to eq(client)
    end
  end

  describe '#openai_api_key' do
    it 'sets the OpenAI API key' do
      client.openai_api_key('test-key')
      expect(client.config.openai_api_key).to eq('test-key')
    end

    it 'returns self for chaining' do
      result = client.openai_api_key('test-key')
      expect(result).to eq(client)
    end
  end

  describe '#anthropic_api_key' do
    it 'sets the Anthropic API key' do
      client.anthropic_api_key('test-key')
      expect(client.config.anthropic_api_key).to eq('test-key')
    end

    it 'returns self for chaining' do
      result = client.anthropic_api_key('test-key')
      expect(result).to eq(client)
    end
  end

  describe '#conventions_files' do
    it 'adds conventions files' do
      file1 = Tempfile.new(['conventions1', '.md'])
      file2 = Tempfile.new(['conventions2', '.md'])

      client.conventions_files([file1.path, file2.path])
      expect(client.config.conventions_files).to include(file1.path, file2.path)

      file1.close
      file1.unlink
      file2.close
      file2.unlink
    end

    it 'returns self for chaining' do
      file = Tempfile.new(['conventions', '.md'])
      result = client.conventions_files([file.path])
      expect(result).to eq(client)
      file.close
      file.unlink
    end

    it 'validates file existence' do
      expect do
        client.conventions_files(['non_existent_file.md'])
      end.to raise_error(AiderRuby::ErrorHandling::FileError)
    end

    it 'skips validation when validate: false' do
      expect do
        client.conventions_files(['non_existent_file.md'], validate: false)
      end.not_to raise_error
    end
  end

  describe '#add_read_files' do
    it 'adds read files to the config' do
      file1 = Tempfile.new(['read1', '.md'])
      file2 = Tempfile.new(['read2', '.md'])

      client.add_read_files([file1.path, file2.path])
      expect(client.config.read_files).to include(file1.path, file2.path)

      file1.close
      file1.unlink
      file2.close
      file2.unlink
    end

    it 'returns self for chaining' do
      file = Tempfile.new(['read', '.md'])
      result = client.add_read_files([file.path])
      expect(result).to eq(client)
      file.close
      file.unlink
    end

    it 'filters by extensions' do
      file1 = Tempfile.new(['read1', '.md'])
      file2 = Tempfile.new(['read2', '.txt'])

      client.add_read_files([file1.path, file2.path], extensions: ['.md'])
      expect(client.config.read_files).to include(file1.path)
      expect(client.config.read_files).not_to include(file2.path)

      file1.close
      file1.unlink
      file2.close
      file2.unlink
    end
  end

  describe '#clear_read_files' do
    it 'clears all read files' do
      file = Tempfile.new(['read', '.md'])
      client.add_read_files([file.path])
      client.clear_read_files
      expect(client.read_files_list).to be_empty
      file.close
      file.unlink
    end
  end

  describe '#read_files_list' do
    it 'returns the list of read files' do
      file = Tempfile.new(['read', '.md'])
      client.add_read_files([file.path])
      expect(client.read_files_list).to include(file.path)
      file.close
      file.unlink
    end
  end

  describe '#edit_format_diff' do
    it 'sets edit format to diff' do
      client.edit_format_diff(true)
      expect(client.config.edit_format_diff).to be true
    end

    it 'returns self for chaining' do
      result = client.edit_format_diff(true)
      expect(result).to eq(client)
    end
  end

  describe '#use_temperature' do
    it 'sets use_temperature setting' do
      client.use_temperature(true)
      expect(client.config.use_temperature).to be true
    end

    it 'returns self for chaining' do
      result = client.use_temperature(true)
      expect(result).to eq(client)
    end
  end

  describe '#use_system_prompt' do
    it 'sets use_system_prompt setting' do
      client.use_system_prompt(true)
      expect(client.config.use_system_prompt).to be true
    end

    it 'returns self for chaining' do
      result = client.use_system_prompt(true)
      expect(result).to eq(client)
    end
  end

  describe '#use_repo_map' do
    it 'sets use_repo_map setting' do
      client.use_repo_map(true)
      expect(client.config.use_repo_map).to be true
    end

    it 'returns self for chaining' do
      result = client.use_repo_map(true)
      expect(result).to eq(client)
    end
  end

  describe '#add_alias' do
    it 'adds an alias setting' do
      client.add_alias('sonnet', 'claude-3-5-sonnet-20241022')
      expect(client.config.alias_settings).to include({ alias: 'sonnet', model: 'claude-3-5-sonnet-20241022' })
    end

    it 'returns self for chaining' do
      result = client.add_alias('sonnet', 'claude-3-5-sonnet-20241022')
      expect(result).to eq(client)
    end
  end

  describe 'ModelConfiguration methods' do
    it 'reasoning_effort sets reasoning effort' do
      client.reasoning_effort('high')
      expect(client.config.reasoning_effort).to eq('high')
    end

    it 'thinking_tokens sets thinking tokens' do
      client.thinking_tokens('8k')
      expect(client.config.thinking_tokens).to eq('8k')
    end

    it 'extra_params sets extra params' do
      params = { temperature: 0.8 }
      client.extra_params(params)
      expect(client.config.extra_params).to eq(params)
    end

    it 'weak_model_name sets weak model' do
      client.weak_model_name('gpt-4o-mini')
      expect(client.config.weak_model_name).to eq('gpt-4o-mini')
    end

    it 'editor_model_name sets editor model' do
      client.editor_model_name('gpt-4o')
      expect(client.config.editor_model_name).to eq('gpt-4o')
    end
  end

  describe 'OutputConfiguration methods' do
    it 'dark_mode enables dark mode' do
      client.dark_mode(true)
      expect(client.config.dark_mode).to be true
    end

    it 'light_mode enables light mode' do
      client.light_mode(true)
      expect(client.config.light_mode).to be true
    end

    it 'pretty enables pretty output' do
      client.pretty(true)
      expect(client.config.pretty).to be true
    end

    it 'stream enables streaming' do
      client.stream(true)
      expect(client.config.stream).to be true
    end
  end

  describe 'GitConfiguration methods' do
    it 'git enables git' do
      client.git(true)
      expect(client.config.git).to be true
    end

    it 'auto_commits enables auto commits' do
      client.auto_commits(true)
      expect(client.config.auto_commits).to be true
    end
  end

  describe 'LintTestConfiguration methods' do
    it 'lint enables linting' do
      client.lint(true)
      expect(client.config.lint).to be true
    end

    it 'auto_lint enables auto lint' do
      client.auto_lint(true)
      expect(client.config.auto_lint).to be true
    end

    it 'test enables testing' do
      client.test(true)
      expect(client.config.test).to be true
    end

    it 'auto_test enables auto test' do
      client.auto_test(true)
      expect(client.config.auto_test).to be true
    end
  end

  describe 'GeneralConfiguration methods' do
    it 'vim enables vim mode' do
      client.vim(true)
      expect(client.config.vim).to be true
    end

    it 'chat_language sets chat language' do
      client.chat_language('fr')
      expect(client.config.chat_language).to eq('fr')
    end

    it 'verbose enables verbose output' do
      client.verbose(true)
      expect(client.config.verbose).to be true
    end

    it 'encoding sets encoding' do
      client.encoding('utf-16')
      expect(client.config.encoding).to eq('utf-16')
    end

    it 'line_endings sets line endings' do
      client.line_endings('lf')
      expect(client.config.line_endings).to eq('lf')
    end
  end
end

RSpec.describe AiderRuby::Models do
  describe '.list_providers' do
    it 'returns all providers' do
      providers = AiderRuby::Models.list_providers
      expect(providers).to include(:openai, :anthropic, :google, :groq)
    end
  end

  describe '.list_models' do
    it 'returns all models when no provider specified' do
      models = AiderRuby::Models.list_models
      expect(models).to include('gpt-4o', 'claude-3-5-sonnet-20241022')
    end

    it 'returns models for specific provider' do
      models = AiderRuby::Models.list_models(:openai)
      expect(models).to include('gpt-4o', 'gpt-4o-mini', 'gpt-4-turbo')
    end
  end

  describe '.supported_model?' do
    it 'returns true for supported models' do
      expect(AiderRuby::Models.supported_model?('gpt-4o')).to be true
      expect(AiderRuby::Models.supported_model?('claude-3-5-sonnet-20241022')).to be true
    end

    it 'returns false for unsupported models' do
      expect(AiderRuby::Models.supported_model?('unknown-model')).to be false
    end
  end

  describe '.provider_for_model' do
    it 'returns the provider for a model' do
      expect(AiderRuby::Models.provider_for_model('gpt-4o')).to eq(:openai)
      expect(AiderRuby::Models.provider_for_model('claude-3-5-sonnet-20241022')).to eq(:anthropic)
    end

    it 'returns nil for unknown models' do
      expect(AiderRuby::Models.provider_for_model('unknown-model')).to be_nil
    end
  end

  describe '.is_reasoning_model?' do
    it 'returns true for reasoning models' do
      expect(AiderRuby::Models.is_reasoning_model?('o1-preview')).to be true
      expect(AiderRuby::Models.is_reasoning_model?('o1-mini')).to be true
    end

    it 'returns false for non-reasoning models' do
      expect(AiderRuby::Models.is_reasoning_model?('gpt-4o')).to be false
    end
  end

  describe '.has_vision?' do
    it 'returns true for vision models' do
      expect(AiderRuby::Models.has_vision?('gpt-4o')).to be true
      expect(AiderRuby::Models.has_vision?('claude-3-5-sonnet-20241022')).to be true
    end

    it 'returns false for non-vision models' do
      expect(AiderRuby::Models.has_vision?('gpt-3.5-turbo')).to be false
    end
  end

  describe '.model_info' do
    it 'returns model information' do
      info = AiderRuby::Models.model_info('gpt-4o')
      expect(info[:name]).to eq('gpt-4o')
      expect(info[:provider]).to eq(:openai)
      expect(info[:reasoning]).to be false
      expect(info[:vision]).to be true
      expect(info[:context_window]).to eq(128_000)
      expect(info[:cost_per_token]).to be_a(Hash)
    end

    it 'returns nil for unknown models' do
      expect(AiderRuby::Models.model_info('unknown-model')).to be_nil
    end
  end

  describe '.recommended_models' do
    it 'returns recommended models' do
      recommended = AiderRuby::Models.recommended_models
      expect(recommended).to have_key(:best_overall)
      expect(recommended).to have_key(:fastest)
      expect(recommended).to have_key(:cheapest)
      expect(recommended).to have_key(:reasoning)
      expect(recommended).to have_key(:coding)
      expect(recommended).to have_key(:vision)
    end
  end
end

RSpec.describe AiderRuby::TaskExecutor do
  let(:client) { AiderRuby::Client::Client.new }
  let(:executor) { AiderRuby::TaskExecutor.new(client) }

  describe '#initialize' do
    it 'creates a task executor with a client' do
      expect(executor.client).to eq(client)
      expect(executor.task_history).to be_empty
    end
  end

  describe '#get_task_history' do
    it 'returns empty history initially' do
      history = executor.get_task_history
      expect(history).to be_empty
    end

    it 'filters by type' do
      executor.instance_variable_set(:@task_history, [
                                       { id: '1', type: :coding, status: :completed },
                                       { id: '2', type: :refactoring, status: :completed }
                                     ])

      coding_tasks = executor.get_task_history(type: :coding)
      expect(coding_tasks.length).to eq(1)
      expect(coding_tasks.first[:type]).to eq(:coding)
    end

    it 'filters by status' do
      executor.instance_variable_set(:@task_history, [
                                       { id: '1', type: :coding, status: :completed },
                                       { id: '2', type: :coding, status: :failed }
                                     ])

      completed_tasks = executor.get_task_history(status: :completed)
      expect(completed_tasks.length).to eq(1)
      expect(completed_tasks.first[:status]).to eq(:completed)
    end

    it 'filters by since date' do
      past_time = Time.now - 3600
      recent_time = Time.now

      executor.instance_variable_set(:@task_history, [
                                       { id: '1', type: :coding, status: :completed, created_at: past_time },
                                       { id: '2', type: :coding, status: :completed, created_at: recent_time }
                                     ])

      recent_tasks = executor.get_task_history(since: Time.now - 1800)
      expect(recent_tasks.length).to eq(1)
      expect(recent_tasks.first[:id]).to eq('2')
    end
  end

  describe '#get_task' do
    it 'returns task by ID' do
      task = { id: 'test-task', type: :coding, status: :completed }
      executor.instance_variable_set(:@task_history, [task])

      found_task = executor.get_task('test-task')
      expect(found_task).to eq(task)
    end

    it 'returns nil for non-existent task' do
      found_task = executor.get_task('non-existent')
      expect(found_task).to be_nil
    end
  end

  describe '#export_history' do
    it 'exports history as JSON string' do
      task = { id: 'test-task', type: :coding, status: :completed }
      executor.instance_variable_set(:@task_history, [task])

      json = executor.export_history
      expect(json).to be_a(String)
      expect(JSON.parse(json)).to be_an(Array)
    end

    it 'exports history to file' do
      task = { id: 'test-task', type: :coding, status: :completed }
      executor.instance_variable_set(:@task_history, [task])

      file = Tempfile.new(['history', '.json'])
      executor.export_history(file.path)

      content = File.read(file.path)
      expect(JSON.parse(content)).to be_an(Array)

      file.close
      file.unlink
    end
  end

  describe '#import_history' do
    it 'imports history from JSON file' do
      task = { id: 'test-task', type: 'coding', status: 'completed' }

      file = Tempfile.new(['history', '.json'])
      File.write(file.path, JSON.generate([task]))

      executor.import_history(file.path)
      expect(executor.task_history.length).to eq(1)
      expect(executor.task_history.first[:id]).to eq('test-task')

      file.close
      file.unlink
    end
  end
end

RSpec.describe AiderRuby::Validation::Validator do
  describe '.validate_model_name' do
    it 'accepts valid models' do
      expect do
        AiderRuby::Validation::Validator.validate_model_name('gpt-4o')
      end.not_to raise_error
    end

    it 'raises error for invalid models' do
      expect do
        AiderRuby::Validation::Validator.validate_model_name('invalid-model')
      end.to raise_error(AiderRuby::ErrorHandling::ValidationError)
    end

    it 'accepts nil' do
      expect do
        AiderRuby::Validation::Validator.validate_model_name(nil)
      end.not_to raise_error
    end

    it 'accepts empty string' do
      expect do
        AiderRuby::Validation::Validator.validate_model_name('')
      end.not_to raise_error
    end
  end

  describe '.validate_edit_format' do
    it 'accepts valid edit formats' do
      expect do
        AiderRuby::Validation::Validator.validate_edit_format('diff')
      end.not_to raise_error
    end

    it 'raises error for invalid edit formats' do
      expect do
        AiderRuby::Validation::Validator.validate_edit_format('invalid')
      end.to raise_error(AiderRuby::ErrorHandling::ValidationError)
    end
  end

  describe '.validate_reasoning_effort' do
    it 'accepts valid reasoning efforts' do
      expect do
        AiderRuby::Validation::Validator.validate_reasoning_effort('high')
      end.not_to raise_error
    end

    it 'raises error for invalid reasoning efforts' do
      expect do
        AiderRuby::Validation::Validator.validate_reasoning_effort('extreme')
      end.to raise_error(AiderRuby::ErrorHandling::ValidationError)
    end
  end

  describe '.validate_thinking_tokens' do
    it 'accepts valid token formats' do
      expect do
        AiderRuby::Validation::Validator.validate_thinking_tokens('8k')
      end.not_to raise_error

      expect do
        AiderRuby::Validation::Validator.validate_thinking_tokens('1000')
      end.not_to raise_error
    end

    it 'raises error for invalid token formats' do
      expect do
        AiderRuby::Validation::Validator.validate_thinking_tokens('invalid')
      end.to raise_error(AiderRuby::ErrorHandling::ValidationError)
    end
  end

  describe '.validate_voice_format' do
    it 'accepts valid voice formats' do
      expect do
        AiderRuby::Validation::Validator.validate_voice_format('wav')
      end.not_to raise_error
    end

    it 'raises error for invalid voice formats' do
      expect do
        AiderRuby::Validation::Validator.validate_voice_format('ogg')
      end.to raise_error(AiderRuby::ErrorHandling::ValidationError)
    end
  end

  describe '.validate_line_endings' do
    it 'accepts valid line endings' do
      expect do
        AiderRuby::Validation::Validator.validate_line_endings('lf')
      end.not_to raise_error
    end

    it 'raises error for invalid line endings' do
      expect do
        AiderRuby::Validation::Validator.validate_line_endings('invalid')
      end.to raise_error(AiderRuby::ErrorHandling::ValidationError)
    end
  end

  describe '.validate_encoding' do
    it 'accepts valid encodings' do
      expect do
        AiderRuby::Validation::Validator.validate_encoding('utf-8')
      end.not_to raise_error
    end

    it 'raises error for invalid encodings' do
      expect do
        AiderRuby::Validation::Validator.validate_encoding('invalid')
      end.to raise_error(AiderRuby::ErrorHandling::ValidationError)
    end
  end

  describe '.validate_file_path' do
    it 'accepts existing files' do
      file = Tempfile.new(['test', '.txt'])
      expect do
        AiderRuby::Validation::Validator.validate_file_path(file.path)
      end.not_to raise_error
      file.close
      file.unlink
    end

    it 'raises error for non-existent files' do
      expect do
        AiderRuby::Validation::Validator.validate_file_path('/non/existent/file.txt')
      end.to raise_error(AiderRuby::ErrorHandling::FileError)
    end
  end

  describe '.validate_api_key' do
    it 'accepts valid API keys' do
      expect do
        AiderRuby::Validation::Validator.validate_api_key('sk-1234567890', 'OpenAI')
      end.not_to raise_error
    end

    it 'raises error for short API keys' do
      expect do
        AiderRuby::Validation::Validator.validate_api_key('short', 'OpenAI')
      end.to raise_error(AiderRuby::ErrorHandling::ValidationError)
    end
  end

  describe '.validate_timeout' do
    it 'accepts valid timeouts' do
      expect do
        AiderRuby::Validation::Validator.validate_timeout(60)
      end.not_to raise_error
    end

    it 'raises error for invalid timeouts' do
      expect do
        AiderRuby::Validation::Validator.validate_timeout(0)
      end.to raise_error(AiderRuby::ErrorHandling::ValidationError)

      expect do
        AiderRuby::Validation::Validator.validate_timeout(4000)
      end.to raise_error(AiderRuby::ErrorHandling::ValidationError)
    end
  end

  describe '.validate_map_tokens' do
    it 'accepts valid map tokens' do
      expect do
        AiderRuby::Validation::Validator.validate_map_tokens(1024)
      end.not_to raise_error
    end

    it 'raises error for invalid map tokens' do
      expect do
        AiderRuby::Validation::Validator.validate_map_tokens(0)
      end.to raise_error(AiderRuby::ErrorHandling::ValidationError)

      expect do
        AiderRuby::Validation::Validator.validate_map_tokens(200_000)
      end.to raise_error(AiderRuby::ErrorHandling::ValidationError)
    end
  end
end

RSpec.describe AiderRuby::ErrorHandling do
  describe '.handle_configuration_error' do
    it 'raises ConfigurationError for ENOENT' do
      error = Errno::ENOENT.new('config.yml')
      expect do
        AiderRuby::ErrorHandling.handle_configuration_error(error)
      end.to raise_error(AiderRuby::ErrorHandling::ConfigurationError)
    end

    it 'raises ConfigurationError for Psych::SyntaxError' do
      error = Psych::SyntaxError.new('file', 1, 1, 0, 'problem', 'context')
      expect do
        AiderRuby::ErrorHandling.handle_configuration_error(error)
      end.to raise_error(AiderRuby::ErrorHandling::ConfigurationError)
    end

    it 'raises ConfigurationError for JSON::ParserError' do
      error = JSON::ParserError.new('invalid json')
      expect do
        AiderRuby::ErrorHandling.handle_configuration_error(error)
      end.to raise_error(AiderRuby::ErrorHandling::ConfigurationError)
    end

    it 'raises ConfigurationError for other errors' do
      error = StandardError.new('generic error')
      expect do
        AiderRuby::ErrorHandling.handle_configuration_error(error)
      end.to raise_error(AiderRuby::ErrorHandling::ConfigurationError)
    end
  end

  describe '.handle_model_error' do
    it 'raises ModelError for ArgumentError' do
      error = ArgumentError.new('invalid argument')
      expect do
        AiderRuby::ErrorHandling.handle_model_error(error)
      end.to raise_error(AiderRuby::ErrorHandling::ModelError)
    end

    it 'raises ModelError for other errors' do
      error = StandardError.new('model error')
      expect do
        AiderRuby::ErrorHandling.handle_model_error(error)
      end.to raise_error(AiderRuby::ErrorHandling::ModelError)
    end
  end

  describe '.handle_execution_error' do
    it 'raises ExecutionError for ENOENT' do
      error = Errno::ENOENT.new('aider')
      expect do
        AiderRuby::ErrorHandling.handle_execution_error(error)
      end.to raise_error(AiderRuby::ErrorHandling::ExecutionError)
    end

    it 'raises ExecutionError for EACCES' do
      error = Errno::EACCES.new('aider')
      expect do
        AiderRuby::ErrorHandling.handle_execution_error(error)
      end.to raise_error(AiderRuby::ErrorHandling::ExecutionError)
    end
  end

  describe '.handle_file_error' do
    it 'raises FileError for ENOENT' do
      error = Errno::ENOENT.new('file.txt')
      expect do
        AiderRuby::ErrorHandling.handle_file_error(error)
      end.to raise_error(AiderRuby::ErrorHandling::FileError)
    end

    it 'raises FileError for EACCES' do
      error = Errno::EACCES.new('file.txt')
      expect do
        AiderRuby::ErrorHandling.handle_file_error(error)
      end.to raise_error(AiderRuby::ErrorHandling::FileError)
    end
  end

  describe '.handle_validation_error' do
    it 'raises ValidationError with message' do
      expect do
        AiderRuby::ErrorHandling.handle_validation_error('Invalid input')
      end.to raise_error(AiderRuby::ErrorHandling::ValidationError, 'Invalid input')
    end
  end
end
