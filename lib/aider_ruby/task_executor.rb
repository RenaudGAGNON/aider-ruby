require 'json'
require 'tempfile'

module AiderRuby
  class TaskExecutor
    attr_reader :client, :task_history

    def initialize(client)
      @client = client
      @task_history = []
    end

    # Execute a coding task
    def execute_coding_task(description, files = [], options = {})
      execute_task(:coding, description, files, options)
    end

    # Execute a refactoring task
    def execute_refactoring_task(description, files = [], options = {})
      task_options = {
        git: true,
        auto_commits: true,
        lint: true,
        auto_lint: true
      }
      execute_task(:refactoring, description, files, options, task_options)
    end

    # Execute a debugging task
    def execute_debugging_task(description, files = [], options = {})
      task_options = {
        verbose: true,
        test: true,
        auto_test: true,
        show_diffs: true
      }
      execute_task(:debugging, description, files, options, task_options)
    end

    # Execute a documentation task
    def execute_documentation_task(description, files = [], options = {})
      task_options = {
        model: Constants::DEFAULT_DOC_MODEL,
        pretty: true
      }
      execute_task(:documentation, description, files, options, task_options)
    end

    # Execute a test generation task
    def execute_test_generation_task(description, files = [], options = {})
      task_options = {
        test: true,
        auto_test: true,
        test_cmd: Constants::DEFAULT_TEST_CMD
      }
      execute_task(:test_generation, description, files, options, task_options)
    end

    # Execute a multi-step task with checkpoints
    def execute_multi_step_task(steps, files = [], options = {})
      task = Task.new(
        type: :multi_step,
        description: "Multi-step task with #{steps.length} steps",
        files: files
      )
      task.steps.replace(Array(steps))

      @task_history << task

      execute_with_tracking(task) do
        files.each { |file| @client.add_files(file) }

        results = []
        steps.each_with_index do |step, index|
          step_description = step.is_a?(Hash) ? step[:description] : step.to_s
          step_result = @client.execute(step_description, options)
          results << step_result

          # Add checkpoint
          if step.is_a?(Hash)
            task.steps[index][:result] = step_result
            task.steps[index][:completed_at] = Time.now
          end
        end

        results
      end
    end

    # Get task history
    def get_task_history(filter = {})
      tasks = @task_history.map(&:to_h)

      tasks = tasks.select { |task| task[:type] == filter[:type] } if filter[:type]
      tasks = tasks.select { |task| task[:status] == filter[:status] } if filter[:status]
      tasks = tasks.select { |task| task[:created_at] >= filter[:since] } if filter[:since]

      tasks
    end

    # Get task by ID
    def get_task(task_id)
      task = @task_history.find { |t| t.id == task_id }
      task&.to_h
    end

    # Export task history to JSON
    def export_history(file_path = nil)
      history_json = JSON.pretty_generate(@task_history.map(&:to_h))
      
      if file_path
        File.write(file_path, history_json)
      else
        history_json
      end
    end

    # Import task history from JSON
    def import_history(file_path)
      history_data = JSON.parse(File.read(file_path), symbolize_names: true)
      
      history_data.each do |task_data|
        # Convert string keys/symbols to symbols for consistency
        type = task_data[:type] || task_data['type']
        type = type.to_sym if type.is_a?(String)
        
        task = Task.new(
          type: type,
          description: task_data[:description] || task_data['description'],
          files: task_data[:files] || task_data['files'] || []
        )
        
        # Restore task state
        task.instance_variable_set(:@id, task_data[:id] || task_data['id'])
        status = task_data[:status] || task_data['status']
        status = status.to_sym if status.is_a?(String)
        task.instance_variable_set(:@status, status)
        task.instance_variable_set(:@result, task_data[:result] || task_data['result'])
        task.instance_variable_set(:@error, task_data[:error] || task_data['error'])
        task.instance_variable_set(:@steps, task_data[:steps] || task_data['steps'] || [])
        
        if task_data[:created_at] || task_data['created_at']
          created_at = task_data[:created_at] || task_data['created_at']
          task.instance_variable_set(:@created_at, Time.parse(created_at.to_s))
        end
        if task_data[:completed_at] || task_data['completed_at']
          completed_at = task_data[:completed_at] || task_data['completed_at']
          task.instance_variable_set(:@completed_at, Time.parse(completed_at.to_s))
        end
        if task_data[:failed_at] || task_data['failed_at']
          failed_at = task_data[:failed_at] || task_data['failed_at']
          task.instance_variable_set(:@failed_at, Time.parse(failed_at.to_s))
        end
        
        @task_history << task
      end
    end

    private

    def execute_task(type, description, files, options, task_options = {})
      task = Task.new(type: type, description: description, files: files)
      @task_history << task

      execute_with_tracking(task) do
        files.each { |file| @client.add_files(file) }
        merged_options = task_options.merge(options)
        @client.execute(description, merged_options)
      end
    end

    def execute_with_tracking(task)
      task.running!
      result = yield
      task.completed!(result)
      result
    rescue StandardError => e
      task.failed!(e)
      raise e
    end
  end
end
