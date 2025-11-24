require 'spec_helper'
require 'aider_ruby'
require 'tempfile'

RSpec.describe 'AiderRuby::Client Execution Methods' do
  let(:client) { AiderRuby::Client::Client.new }

  describe '#add_folder' do
    it 'adds files from a folder' do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, 'file1.rb'), 'test')
        File.write(File.join(dir, 'file2.rb'), 'test')
        File.write(File.join(dir, 'file3.txt'), 'test')

        client.add_folder(dir)
        expect(client.files.length).to eq(3)
      end
    end

    it 'filters by extensions' do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, 'file1.rb'), 'test')
        File.write(File.join(dir, 'file2.rb'), 'test')
        File.write(File.join(dir, 'file3.txt'), 'test')

        client.add_folder(dir, extensions: ['.rb'])
        expect(client.files.length).to eq(2)
      end
    end

    it 'excludes files matching patterns' do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, 'file1.rb'), 'test')
        File.write(File.join(dir, 'test_file.rb'), 'test')

        client.add_folder(dir, exclude_patterns: ['test_'])
        expect(client.files.length).to eq(1)
        expect(client.files).to include(File.join(dir, 'file1.rb'))
      end
    end

    it 'excludes files matching regex patterns' do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, 'file1.rb'), 'test')
        File.write(File.join(dir, 'spec_file.rb'), 'test')

        client.add_folder(dir, exclude_patterns: [/spec_/])
        expect(client.files.length).to eq(1)
      end
    end
  end

  describe '#add_read_only_folder' do
    it 'adds files from a folder as read-only' do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, 'file1.rb'), 'test')
        File.write(File.join(dir, 'file2.rb'), 'test')

        client.add_read_only_folder(dir)
        expect(client.read_only_files.length).to eq(2)
      end
    end

    it 'filters by extensions' do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, 'file1.rb'), 'test')
        File.write(File.join(dir, 'file2.txt'), 'test')

        client.add_read_only_folder(dir, extensions: ['.rb'])
        expect(client.read_only_files.length).to eq(1)
      end
    end
  end

  describe '#add_read_files_from_folder' do
    it 'adds read files from folder' do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, 'doc1.md'), 'test')
        File.write(File.join(dir, 'doc2.md'), 'test')

        client.add_read_files_from_folder(dir)
        expect(client.config.read_files.length).to eq(2)
      end
    end

    it 'filters by extensions' do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, 'doc1.md'), 'test')
        File.write(File.join(dir, 'doc2.txt'), 'test')

        client.add_read_files_from_folder(dir, extensions: ['.md'])
        expect(client.config.read_files.length).to eq(1)
      end
    end

    it 'excludes files matching patterns' do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, 'doc1.md'), 'test')
        File.write(File.join(dir, 'temp_doc.md'), 'test')

        client.add_read_files_from_folder(dir, exclude_patterns: ['temp_'])
        expect(client.config.read_files.length).to eq(1)
      end
    end
  end

  describe 'private #build_command_args' do
    it 'builds command arguments with files' do
      client.add_files('test1.rb')
      client.add_files('test2.rb')
      client.add_read_only_file('readme.md')

      args = client.send(:build_command_args)

      expect(args).to include('aider')
      expect(args).to include('--file', 'test1.rb')
      expect(args).to include('--file', 'test2.rb')
      expect(args).to include('--read', 'readme.md')
    end

    it 'includes config options' do
      client.model('gpt-4o')
      client.verbose(true)

      args = client.send(:build_command_args)

      expect(args).to include('--model', 'gpt-4o')
      expect(args).to include('--verbose')
    end
  end

  describe 'private #add_cli_options' do
    it 'adds config_file option' do
      args = ['aider']
      client.send(:add_cli_options, args, { config_file: 'config.yml' })

      expect(args).to include('--config', 'config.yml')
    end

    it 'adds env_file option' do
      args = ['aider']
      client.send(:add_cli_options, args, { env_file: '.env' })

      expect(args).to include('--env-file', '.env')
    end

    it 'adds dry_run option' do
      args = ['aider']
      client.send(:add_cli_options, args, { dry_run: true })

      expect(args).to include('--dry-run')
    end

    it 'adds verbose option' do
      args = ['aider']
      client.send(:add_cli_options, args, { verbose: true })

      expect(args).to include('--verbose')
    end

    it 'adds yes_always option' do
      args = ['aider']
      client.send(:add_cli_options, args, { yes_always: true })

      expect(args).to include('--yes-always')
    end
  end

  describe 'ConventionConfiguration methods' do
    describe '#edit_format_whole' do
      it 'sets edit_format_whole' do
        client.edit_format_whole(true)
        expect(client.config.edit_format_whole).to be true
      end
    end

    describe '#edit_format_diff_fenced' do
      it 'sets edit_format_diff_fenced' do
        client.edit_format_diff_fenced(true)
        expect(client.config.edit_format_diff_fenced).to be true
      end
    end

    describe '#editor_edit_format_whole' do
      it 'sets editor_edit_format_whole' do
        client.editor_edit_format_whole(true)
        expect(client.config.editor_edit_format_whole).to be true
      end
    end

    describe '#editor_edit_format_diff' do
      it 'sets editor_edit_format_diff' do
        client.editor_edit_format_diff(true)
        expect(client.config.editor_edit_format_diff).to be true
      end
    end

    describe '#editor_edit_format_diff_fenced' do
      it 'sets editor_edit_format_diff_fenced' do
        client.editor_edit_format_diff_fenced(true)
        expect(client.config.editor_edit_format_diff_fenced).to be true
      end
    end
  end

  describe 'ModelConfiguration methods' do
    describe '#model_settings_file' do
      it 'sets model_settings_file' do
        client.model_settings_file('model_settings.yml')
        expect(client.config.model_settings_file).to eq('model_settings.yml')
      end
    end

    describe '#model_metadata_file' do
      it 'sets model_metadata_file' do
        client.model_metadata_file('metadata.json')
        expect(client.config.model_metadata_file).to eq('metadata.json')
      end
    end

    describe '#reasoning_tag' do
      it 'sets reasoning_tag' do
        client.reasoning_tag('thinking')
        expect(client.config.reasoning_tag).to eq('thinking')
      end
    end
  end

  describe 'GeneralConfiguration methods' do
    describe '#disable_playwright' do
      it 'disables playwright' do
        client.disable_playwright(true)
        expect(client.config.disable_playwright).to be true
      end
    end

    describe '#commit_language' do
      it 'sets commit language' do
        client.commit_language('en')
        expect(client.config.commit_language).to eq('en')
      end
    end

    describe '#yes_always' do
      it 'sets yes_always' do
        client.yes_always(true)
        expect(client.config.yes_always).to be true
      end
    end

    describe '#suggest_shell_commands' do
      it 'sets suggest_shell_commands' do
        client.suggest_shell_commands(false)
        expect(client.config.suggest_shell_commands).to be false
      end
    end

    describe '#fancy_input' do
      it 'sets fancy_input' do
        client.fancy_input(false)
        expect(client.config.fancy_input).to be false
      end
    end

    describe '#multiline' do
      it 'sets multiline' do
        client.multiline(true)
        expect(client.config.multiline).to be true
      end
    end

    describe '#notifications' do
      it 'sets notifications' do
        client.notifications(true)
        expect(client.config.notifications).to be true
      end
    end

    describe '#notifications_command' do
      it 'sets notifications_command' do
        client.notifications_command('notify-send')
        expect(client.config.notifications_command).to eq('notify-send')
      end
    end

    describe '#detect_urls' do
      it 'sets detect_urls' do
        client.detect_urls(false)
        expect(client.config.detect_urls).to be false
      end
    end

    describe '#editor' do
      it 'sets editor' do
        client.editor('vim')
        expect(client.config.editor).to eq('vim')
      end
    end

    describe '#shell_completions' do
      it 'sets shell_completions' do
        client.shell_completions(true)
        expect(client.config.shell_completions).to be true
      end
    end
  end

  describe 'block configuration' do
    it 'accepts block for configuration' do
      client = AiderRuby::Client::Client.new do |config|
        config.model = 'gpt-4o'
        config.verbose = true
      end

      expect(client.config.model).to eq('gpt-4o')
      expect(client.config.verbose).to be true
    end
  end
end

RSpec.describe 'AiderRuby::TaskExecutor Task Methods' do
  let(:client) { AiderRuby::Client::Client.new }
  let(:executor) { AiderRuby::TaskExecutor.new(client) }

  describe 'Task creation' do
    it 'creates tasks with Task class' do
      allow(client).to receive(:add_files).and_return(client)
      allow(client).to receive(:execute).and_return('Success')

      executor.execute_coding_task('Add new feature', ['file1.rb'])

      expect(executor.task_history.length).to eq(1)
      expect(executor.task_history.first).to be_a(AiderRuby::Task)
    end
  end

  describe '#execute_coding_task' do
    it 'creates a coding task entry' do
      allow(client).to receive(:add_files).and_return(client)
      allow(client).to receive(:execute).and_return('Success')

      executor.execute_coding_task('Add new feature', ['file1.rb'])

      expect(executor.task_history.length).to eq(1)
      task = executor.task_history.first
      expect(task.type).to eq(:coding)
      expect(task.status).to eq(:completed)
    end

    it 'handles errors' do
      allow(client).to receive(:add_files).and_return(client)
      allow(client).to receive(:execute).and_raise(StandardError, 'Execution failed')

      expect do
        executor.execute_coding_task('Add new feature', ['file1.rb'])
      end.to raise_error(StandardError)

      task = executor.task_history.first
      expect(task.status).to eq(:failed)
      expect(task.error).to eq('Execution failed')
    end
  end

  describe '#execute_refactoring_task' do
    it 'creates a refactoring task with proper options' do
      allow(client).to receive(:add_files).and_return(client)
      allow(client).to receive(:execute).and_return('Success')

      executor.execute_refactoring_task('Refactor code', ['file1.rb'])

      expect(executor.task_history.length).to eq(1)
      expect(executor.task_history.first.type).to eq(:refactoring)
    end

    it 'merges refactoring-specific options' do
      allow(client).to receive(:add_files).and_return(client)
      expect(client).to receive(:execute).with(
        'Refactor code',
        hash_including(git: true, auto_commits: true, lint: true, auto_lint: true)
      ).and_return('Success')

      executor.execute_refactoring_task('Refactor code', ['file1.rb'])
    end
  end

  describe '#execute_debugging_task' do
    it 'creates a debugging task with verbose options' do
      allow(client).to receive(:add_files).and_return(client)
      allow(client).to receive(:execute).and_return('Success')

      executor.execute_debugging_task('Fix bug', ['file1.rb'])

      expect(executor.task_history.length).to eq(1)
      expect(executor.task_history.first.type).to eq(:debugging)
    end

    it 'merges debugging-specific options' do
      allow(client).to receive(:add_files).and_return(client)
      expect(client).to receive(:execute).with(
        'Fix bug',
        hash_including(verbose: true, test: true, auto_test: true, show_diffs: true)
      ).and_return('Success')

      executor.execute_debugging_task('Fix bug', ['file1.rb'])
    end
  end

  describe '#execute_documentation_task' do
    it 'creates a documentation task' do
      allow(client).to receive(:add_files).and_return(client)
      allow(client).to receive(:execute).and_return('Success')

      executor.execute_documentation_task('Add docs', ['file1.rb'])

      expect(executor.task_history.length).to eq(1)
      expect(executor.task_history.first.type).to eq(:documentation)
    end

    it 'uses default documentation model' do
      allow(client).to receive(:add_files).and_return(client)
      expect(client).to receive(:execute).with(
        'Add docs',
        hash_including(model: AiderRuby::Constants::DEFAULT_DOC_MODEL, pretty: true)
      ).and_return('Success')

      executor.execute_documentation_task('Add docs', ['file1.rb'])
    end
  end

  describe '#execute_test_generation_task' do
    it 'creates a test generation task' do
      allow(client).to receive(:add_files).and_return(client)
      allow(client).to receive(:execute).and_return('Success')

      executor.execute_test_generation_task('Generate tests', ['file1.rb'])

      expect(executor.task_history.length).to eq(1)
      expect(executor.task_history.first.type).to eq(:test_generation)
    end

    it 'uses default test command' do
      allow(client).to receive(:add_files).and_return(client)
      expect(client).to receive(:execute).with(
        'Generate tests',
        hash_including(test: true, auto_test: true, test_cmd: AiderRuby::Constants::DEFAULT_TEST_CMD)
      ).and_return('Success')

      executor.execute_test_generation_task('Generate tests', ['file1.rb'])
    end
  end

  describe '#execute_multi_step_task' do
    it 'executes multiple steps and tracks them' do
      allow(client).to receive(:add_files).and_return(client)
      allow(client).to receive(:execute).and_return('Step 1 done', 'Step 2 done')

      steps = [
        { description: 'Step 1' },
        { description: 'Step 2' }
      ]

      results = executor.execute_multi_step_task(steps, ['file1.rb'])

      expect(results).to be_an(Array)
      expect(executor.task_history.length).to eq(1)
      expect(executor.task_history.first.type).to eq(:multi_step)
    end

    it 'handles string steps' do
      allow(client).to receive(:add_files).and_return(client)
      allow(client).to receive(:execute).and_return('Step 1 done', 'Step 2 done')

      steps = ['Step 1', 'Step 2']
      results = executor.execute_multi_step_task(steps, ['file1.rb'])

      expect(results).to be_an(Array)
      expect(results.length).to eq(2)
    end

    it 'handles errors in multi-step tasks' do
      allow(client).to receive(:add_files).and_return(client)
      allow(client).to receive(:execute).and_return('Step 1 done').and_raise(StandardError, 'Step 2 failed')

      steps = [
        { description: 'Step 1' },
        { description: 'Step 2' }
      ]

      expect do
        executor.execute_multi_step_task(steps, ['file1.rb'])
      end.to raise_error(StandardError)

      expect(executor.task_history.first.status).to eq(:failed)
    end
  end

  describe '#get_task_history' do
    it 'returns tasks as hashes' do
      allow(client).to receive(:add_files).and_return(client)
      allow(client).to receive(:execute).and_return('Success')

      executor.execute_coding_task('Task 1', [])
      executor.execute_refactoring_task('Task 2', [])

      history = executor.get_task_history
      expect(history).to be_an(Array)
      expect(history.first).to be_a(Hash)
      expect(history.first[:type]).to eq(:coding)
    end

    it 'filters by type' do
      allow(client).to receive(:add_files).and_return(client)
      allow(client).to receive(:execute).and_return('Success')

      executor.execute_coding_task('Task 1', [])
      executor.execute_refactoring_task('Task 2', [])

      history = executor.get_task_history(type: :coding)
      expect(history.length).to eq(1)
      expect(history.first[:type]).to eq(:coding)
    end
  end

  describe '#get_task' do
    it 'returns task as hash by ID' do
      allow(client).to receive(:add_files).and_return(client)
      allow(client).to receive(:execute).and_return('Success')

      executor.execute_coding_task('Task 1', [])
      task_id = executor.task_history.first.id

      task = executor.get_task(task_id)
      expect(task).to be_a(Hash)
      expect(task[:id]).to eq(task_id)
    end
  end

  describe '#export_history and #import_history' do
    it 'exports and imports task history' do
      allow(client).to receive(:add_files).and_return(client)
      allow(client).to receive(:execute).and_return('Success')

      executor.execute_coding_task('Task 1', [])
      executor.execute_refactoring_task('Task 2', [])

      file = Tempfile.new(['history', '.json'])
      executor.export_history(file.path)

      new_executor = AiderRuby::TaskExecutor.new(client)
      new_executor.import_history(file.path)

      expect(new_executor.task_history.length).to eq(2)
      # JSON parsing converts symbols to strings, so we check the string version
      expect(new_executor.task_history.first.type.to_s).to eq('coding')
      expect(new_executor.task_history.last.type.to_s).to eq('refactoring')

      file.close
      file.unlink
    end
  end
end

RSpec.describe 'AiderRuby Additional Coverage' do
  describe 'ConventionConfiguration#add_read_files edge cases' do
    let(:client) { AiderRuby::Client::Client.new }

    it 'filters files with regex exclude patterns' do
      file1 = Tempfile.new(['doc1', '.md'])
      file2 = Tempfile.new(['test_doc', '.md'])

      client.add_read_files([file1.path, file2.path], exclude_patterns: [/^.*test.*/])

      expect(client.config.read_files).to include(file1.path)

      file1.close
      file1.unlink
      file2.close
      file2.unlink
    end

    it 'skips validation when validate: false' do
      expect do
        client.add_read_files(['non_existent.md'], validate: false)
      end.not_to raise_error
    end
  end
end
