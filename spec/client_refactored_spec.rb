require 'spec_helper'
require 'aider_ruby'
require 'tempfile'

RSpec.describe 'AiderRuby::Client Refactored Methods' do
  let(:client) { AiderRuby::Client::Client.new }

  describe 'private #find_files_in_folder' do
    it 'finds all files in a folder' do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, 'file1.rb'), 'test')
        File.write(File.join(dir, 'file2.rb'), 'test')
        subdir = File.join(dir, 'subdir')
        Dir.mkdir(subdir)
        File.write(File.join(subdir, 'file3.rb'), 'test')

        files = client.send(:find_files_in_folder, dir, nil, [])
        expect(files.length).to eq(3)
      end
    end

    it 'filters by extensions' do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, 'file1.rb'), 'test')
        File.write(File.join(dir, 'file2.txt'), 'test')

        files = client.send(:find_files_in_folder, dir, ['.rb'], [])
        expect(files.length).to eq(1)
        expect(files.first).to end_with('.rb')
      end
    end

    it 'excludes files matching patterns' do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, 'file1.rb'), 'test')
        File.write(File.join(dir, 'test_file.rb'), 'test')

        files = client.send(:find_files_in_folder, dir, nil, ['test_'])
        expect(files.length).to eq(1)
      end
    end
  end

  describe 'private #matches_extension?' do
    it 'returns true when no extensions specified' do
      expect(client.send(:matches_extension?, 'file.rb', nil)).to be true
    end

    it 'returns true when extension matches' do
      expect(client.send(:matches_extension?, 'file.rb', ['.rb'])).to be true
    end

    it 'returns false when extension does not match' do
      expect(client.send(:matches_extension?, 'file.txt', ['.rb'])).to be false
    end
  end

  describe 'private #matches_exclude_pattern?' do
    it 'returns false when no patterns specified' do
      expect(client.send(:matches_exclude_pattern?, 'file.rb', [])).to be false
    end

    it 'returns true when string pattern matches' do
      expect(client.send(:matches_exclude_pattern?, 'test_file.rb', ['test_'])).to be true
    end

    it 'returns true when regex pattern matches' do
      expect(client.send(:matches_exclude_pattern?, 'spec_file.rb', [/spec_/])).to be true
    end

    it 'returns false when no patterns match' do
      expect(client.send(:matches_exclude_pattern?, 'file.rb', ['test_'])).to be false
    end
  end

  describe 'private #filter_files' do
    it 'filters files by extensions' do
      files = ['file1.rb', 'file2.txt', 'file3.rb']
      result = client.send(:filter_files, files, ['.rb'], [])
      expect(result).to eq(['file1.rb', 'file3.rb'])
    end

    it 'excludes files matching patterns' do
      files = ['file1.rb', 'test_file.rb', 'file2.rb']
      result = client.send(:filter_files, files, nil, ['test_'])
      expect(result).to eq(['file1.rb', 'file2.rb'])
    end

    it 'applies both filters' do
      files = ['file1.rb', 'file2.txt', 'test_file.rb', 'file3.rb']
      result = client.send(:filter_files, files, ['.rb'], ['test_'])
      expect(result).to eq(['file1.rb', 'file3.rb'])
    end
  end

  describe 'private #filter_by_extensions' do
    it 'filters files by extension' do
      files = ['file1.rb', 'file2.txt']
      result = client.send(:filter_by_extensions, files, ['.rb'])
      expect(result).to eq(['file1.rb'])
    end
  end

  describe 'private #exclude_by_patterns' do
    it 'excludes files matching string patterns' do
      files = ['file1.rb', 'test_file.rb']
      result = client.send(:exclude_by_patterns, files, ['test_'])
      expect(result).to eq(['file1.rb'])
    end

    it 'excludes files matching regex patterns' do
      files = ['file1.rb', 'spec_file.rb']
      result = client.send(:exclude_by_patterns, files, [/spec_/])
      expect(result).to eq(['file1.rb'])
    end
  end

  describe 'private #validate_files' do
    it 'raises error for non-existent files' do
      expect do
        client.send(:validate_files, ['/non/existent/file.rb'])
      end.to raise_error(AiderRuby::ErrorHandling::FileError)
    end

    it 'does not raise error for existing files' do
      file = Tempfile.new(['test', '.rb'])
      expect do
        client.send(:validate_files, [file.path])
      end.not_to raise_error
      file.close
      file.unlink
    end
  end

  describe 'private #execute_non_interactive' do
    it 'raises ExecutionError when command fails' do
      allow(Open3).to receive(:capture3).and_return(['', 'error', double(success?: false, exitstatus: 1)])
      
      expect do
        client.send(:execute_non_interactive, ['invalid_command'])
      end.to raise_error(AiderRuby::ErrorHandling::ExecutionError)
    end

    it 'handles ENOENT errors' do
      allow(Open3).to receive(:capture3).and_raise(Errno::ENOENT.new('command'))
      
      expect do
        client.send(:execute_non_interactive, ['nonexistent'])
      end.to raise_error(AiderRuby::ErrorHandling::ExecutionError)
    end

    it 'handles unexpected errors' do
      allow(Open3).to receive(:capture3).and_raise(StandardError.new('Unexpected'))
      
      expect do
        client.send(:execute_non_interactive, ['command'])
      end.to raise_error(AiderRuby::ErrorHandling::ExecutionError, /Unexpected error/)
    end
  end

  describe 'private #log_command' do
    it 'logs the command to stdout' do
      expect do
        client.send(:log_command, ['aider', '--model', 'gpt-4o'])
      end.to output(/Executing: aider --model gpt-4o/).to_stdout
    end
  end

  describe '#build_command_args uses Constants' do
    it 'uses AIDER_COMMAND constant' do
      args = client.send(:build_command_args)
      expect(args.first).to eq(AiderRuby::Constants::AIDER_COMMAND)
    end
  end
end

