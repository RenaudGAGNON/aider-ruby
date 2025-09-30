require 'json'
require 'tempfile'

module AiderRuby
  class TaskExecutor
    attr_reader :client, :task_history

    def initialize(client)
      @client = client
      @task_history = []
    end

    # Execute a coding task with multiple steps
    def execute_coding_task(description, files = [], options = {})
      task = {
        id: generate_task_id,
        type: :coding,
        description: description,
        files: files,
        status: :pending,
        steps: [],
        created_at: Time.now
      }

      @task_history << task

      begin
        task[:status] = :running

        # Add files to client
        files.each { |file| @client.add_files(file) }

        # Execute the task
        result = @client.execute(description, options)

        task[:status] = :completed
        task[:result] = result
        task[:completed_at] = Time.now

        result
      rescue StandardError => e
        task[:status] = :failed
        task[:error] = e.message
        task[:failed_at] = Time.now
        raise e
      end
    end

    # Execute a refactoring task
    def execute_refactoring_task(description, files = [], options = {})
      task = {
        id: generate_task_id,
        type: :refactoring,
        description: description,
        files: files,
        status: :pending,
        steps: [],
        created_at: Time.now
      }

      @task_history << task

      begin
        task[:status] = :running

        # Add files to client
        files.each { |file| @client.add_files(file) }

        # Enable git and auto-commits for refactoring
        refactoring_options = options.merge(
          git: true,
          auto_commits: true,
          lint: true,
          auto_lint: true
        )

        result = @client.execute(description, refactoring_options)

        task[:status] = :completed
        task[:result] = result
        task[:completed_at] = Time.now

        result
      rescue StandardError => e
        task[:status] = :failed
        task[:error] = e.message
        task[:failed_at] = Time.now
        raise e
      end
    end

    # Execute a debugging task
    def execute_debugging_task(description, files = [], options = {})
      task = {
        id: generate_task_id,
        type: :debugging,
        description: description,
        files: files,
        status: :pending,
        steps: [],
        created_at: Time.now
      }

      @task_history << task

      begin
        task[:status] = :running

        # Add files to client
        files.each { |file| @client.add_files(file) }

        # Enable verbose output and testing for debugging
        debugging_options = options.merge(
          verbose: true,
          test: true,
          auto_test: true,
          show_diffs: true
        )

        result = @client.execute(description, debugging_options)

        task[:status] = :completed
        task[:result] = result
        task[:completed_at] = Time.now

        result
      rescue StandardError => e
        task[:status] = :failed
        task[:error] = e.message
        task[:failed_at] = Time.now
        raise e
      end
    end

    # Execute a documentation task
    def execute_documentation_task(description, files = [], options = {})
      task = {
        id: generate_task_id,
        type: :documentation,
        description: description,
        files: files,
        status: :pending,
        steps: [],
        created_at: Time.now
      }

      @task_history << task

      begin
        task[:status] = :running

        # Add files to client
        files.each { |file| @client.add_files(file) }

        # Use a model good for documentation
        doc_options = options.merge(
          model: 'claude-3-5-sonnet-20241022',
          pretty: true
        )

        result = @client.execute(description, doc_options)

        task[:status] = :completed
        task[:result] = result
        task[:completed_at] = Time.now

        result
      rescue StandardError => e
        task[:status] = :failed
        task[:error] = e.message
        task[:failed_at] = Time.now
        raise e
      end
    end

    # Execute a test generation task
    def execute_test_generation_task(description, files = [], options = {})
      task = {
        id: generate_task_id,
        type: :test_generation,
        description: description,
        files: files,
        status: :pending,
        steps: [],
        created_at: Time.now
      }

      @task_history << task

      begin
        task[:status] = :running

        # Add files to client
        files.each { |file| @client.add_files(file) }

        # Enable testing and auto-test for test generation
        test_options = options.merge(
          test: true,
          auto_test: true,
          test_cmd: 'rspec' # Default to RSpec for Ruby
        )

        result = @client.execute(description, test_options)

        task[:status] = :completed
        task[:result] = result
        task[:completed_at] = Time.now

        result
      rescue StandardError => e
        task[:status] = :failed
        task[:error] = e.message
        task[:failed_at] = Time.now
        raise e
      end
    end

    # Execute a multi-step task with checkpoints
    def execute_multi_step_task(steps, files = [], options = {})
      task = {
        id: generate_task_id,
        type: :multi_step,
        description: "Multi-step task with #{steps.length} steps",
        files: files,
        status: :pending,
        steps: steps,
        created_at: Time.now
      }

      @task_history << task

      begin
        task[:status] = :running

        # Add files to client
        files.each { |file| @client.add_files(file) }

        results = []

        steps.each_with_index do |step, index|
          step_result = @client.execute(step, options)
          results << step_result

          # Add checkpoint
          task[:steps][index][:result] = step_result
          task[:steps][index][:completed_at] = Time.now
        end

        task[:status] = :completed
        task[:result] = results
        task[:completed_at] = Time.now

        results
      rescue StandardError => e
        task[:status] = :failed
        task[:error] = e.message
        task[:failed_at] = Time.now
        raise e
      end
    end

    # Get task history
    def get_task_history(filter = {})
      tasks = @task_history

      tasks = tasks.select { |task| task[:type] == filter[:type] } if filter[:type]

      tasks = tasks.select { |task| task[:status] == filter[:status] } if filter[:status]

      tasks = tasks.select { |task| task[:created_at] >= filter[:since] } if filter[:since]

      tasks
    end

    # Get task by ID
    def get_task(task_id)
      @task_history.find { |task| task[:id] == task_id }
    end

    # Export task history to JSON
    def export_history(file_path = nil)
      if file_path
        File.write(file_path, JSON.pretty_generate(@task_history))
      else
        JSON.pretty_generate(@task_history)
      end
    end

    # Import task history from JSON
    def import_history(file_path)
      history = JSON.parse(File.read(file_path), symbolize_names: true)
      @task_history.concat(history)
    end

    private

    def generate_task_id
      "task_#{Time.now.to_i}_#{rand(1000)}"
    end
  end
end
