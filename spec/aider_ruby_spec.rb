require 'spec_helper'
require 'aider_ruby'

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
  
  describe '#add_file' do
    it 'adds a file to the files list' do
      client.add_file('test.rb')
      expect(client.files).to include('test.rb')
    end
    
    it 'returns self for chaining' do
      result = client.add_file('test.rb')
      expect(result).to eq(client)
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
  
  describe '#conventions_file' do
    it 'sets the conventions file' do
      client.conventions_file('CONVENTIONS.md')
      expect(client.config.conventions_file).to eq('CONVENTIONS.md')
    end
    
    it 'returns self for chaining' do
      result = client.conventions_file('CONVENTIONS.md')
      expect(result).to eq(client)
    end
  end
  
  describe '#add_read_files' do
    it 'adds read files to the config' do
      client.add_read_files(['file1.md', 'file2.md'])
      expect(client.config.read_files).to include('file1.md', 'file2.md')
    end
    
    it 'returns self for chaining' do
      result = client.add_read_files(['file1.md'])
      expect(result).to eq(client)
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
  let(:client) { AiderRuby::Client.new }
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
end
