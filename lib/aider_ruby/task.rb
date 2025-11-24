module AiderRuby
  class Task
    attr_reader :id, :type, :description, :files, :status
    attr_accessor :result, :error, :created_at, :completed_at, :failed_at, :steps

    def initialize(type:, description:, files: [])
      @id = generate_id
      @type = type
      @description = description
      @files = files
      @status = :pending
      @steps = []
      @created_at = Time.now
    end

    def pending!
      @status = :pending
    end

    def running!
      @status = :running
    end

    def completed!(result)
      @status = :completed
      @result = result
      @completed_at = Time.now
    end

    def failed!(error)
      @status = :failed
      @error = error.is_a?(Exception) ? error.message : error
      @failed_at = Time.now
    end

    def to_h
      {
        id: @id,
        type: @type,
        description: @description,
        files: @files,
        status: @status,
        steps: @steps,
        result: @result,
        error: @error,
        created_at: @created_at,
        completed_at: @completed_at,
        failed_at: @failed_at
      }
    end

    private

    def generate_id
      "task_#{Time.now.to_i}_#{rand(1000)}"
    end
  end
end

