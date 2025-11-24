require 'spec_helper'
require 'aider_ruby'

RSpec.describe AiderRuby::Task do
  describe '#initialize' do
    it 'creates a task with required attributes' do
      task = AiderRuby::Task.new(
        type: :coding,
        description: 'Test task',
        files: ['file1.rb']
      )

      expect(task.type).to eq(:coding)
      expect(task.description).to eq('Test task')
      expect(task.files).to eq(['file1.rb'])
      expect(task.status).to eq(:pending)
      expect(task.steps).to eq([])
      expect(task.id).to match(/^task_\d+_\d+$/)
      expect(task.created_at).to be_a(Time)
    end

    it 'defaults files to empty array' do
      task = AiderRuby::Task.new(type: :coding, description: 'Test')
      expect(task.files).to eq([])
    end
  end

  describe '#pending!' do
    it 'sets status to pending' do
      task = AiderRuby::Task.new(type: :coding, description: 'Test')
      task.running!
      task.pending!
      expect(task.status).to eq(:pending)
    end
  end

  describe '#running!' do
    it 'sets status to running' do
      task = AiderRuby::Task.new(type: :coding, description: 'Test')
      task.running!
      expect(task.status).to eq(:running)
    end
  end

  describe '#completed!' do
    it 'sets status to completed and stores result' do
      task = AiderRuby::Task.new(type: :coding, description: 'Test')
      result = 'Task completed successfully'
      
      task.completed!(result)
      
      expect(task.status).to eq(:completed)
      expect(task.result).to eq(result)
      expect(task.completed_at).to be_a(Time)
    end
  end

  describe '#failed!' do
    it 'sets status to failed and stores error message' do
      task = AiderRuby::Task.new(type: :coding, description: 'Test')
      error = StandardError.new('Something went wrong')
      
      task.failed!(error)
      
      expect(task.status).to eq(:failed)
      expect(task.error).to eq('Something went wrong')
      expect(task.failed_at).to be_a(Time)
    end

    it 'accepts string error messages' do
      task = AiderRuby::Task.new(type: :coding, description: 'Test')
      task.failed!('Error message')
      
      expect(task.status).to eq(:failed)
      expect(task.error).to eq('Error message')
    end
  end

  describe '#to_h' do
    it 'converts task to hash' do
      task = AiderRuby::Task.new(
        type: :coding,
        description: 'Test task',
        files: ['file1.rb']
      )
      task.completed!('Success')

      hash = task.to_h

      expect(hash).to be_a(Hash)
      expect(hash[:id]).to eq(task.id)
      expect(hash[:type]).to eq(:coding)
      expect(hash[:description]).to eq('Test task')
      expect(hash[:files]).to eq(['file1.rb'])
      expect(hash[:status]).to eq(:completed)
      expect(hash[:result]).to eq('Success')
      expect(hash[:created_at]).to eq(task.created_at)
      expect(hash[:completed_at]).to eq(task.completed_at)
    end
  end
end

