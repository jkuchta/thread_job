require 'logger'

module ThreadJob
  module Memory
    AVAILABLE = 1
    WORKING = 2
    COMPLETE = 3
    FAILED = 4

    class Record
      attr_accessor :id, :attempts, :job, :job_name, :queue_name, :status
    end

    class Store < JobStore
      def initialize(max_retries=10, logger=Logger.new(STDOUT))
        @jobs = {}
        @failed_jobs = {}
        @mutex = Mutex.new
        @logger = logger
        @max_retries = max_retries
      end

      def save_job(queue_name, job_name, job)
        @mutex.synchronize {
          queued_jobs = @jobs[queue_name] ||= []
          failed_queue_jobs = @failed_jobs[queue_name] ||= []

          rec = Memory::Record.new
          rec.attempts = 0
          rec.id = queued_jobs.count + 1
          rec.job_name = job_name
          rec.job = job
          rec.status = AVAILABLE
          rec.queue_name = queue_name

          queued_jobs.push(rec)
        }

        @logger.info("[MemoryStore] Saved #{job_name}")
      end

      def poll_for_job(queue_name)
        @jobs[queue_name] ||= []
        @logger.debug("[MemoryStore] Polling for jobs, #{@jobs[queue_name].length} in the queue")

        @mutex.synchronize {
          @jobs[queue_name].each do |record|
            if record.status == AVAILABLE || (record.status == FAILED && record.attempts < @max_retries)
              record.status = WORKING
              @logger.debug("[MemoryStore] Sending job '#{record.job_name}' to the thread pool for work")
              return {id: record.id, job: record.job, job_name: record.job_name}
            end
          end
        }

        return nil
      end

      def get_job(queue_name, job_id)
        found_job = false
        if @jobs[queue_name] != nil
          @jobs[queue_name].each do |job|
            if job.id == job_id
              found_job = true
              return job
            end
          end
        end

        @logger.warn("[MemoryStore] unable to get job: #{job_id} from queue: #{queue_name}")

        return nil
      end

      def complete_job(queue_name, job_id)
        @mutex.synchronize {
          job = get_job(queue_name, job_id)
          if job
            @jobs[queue_name].delete(job)
            @logger.info("[MemoryStore] job: '#{job.job_name}' has been completed and removed from the queue")
          end
        }
      end

      def fail_job(queue_name, job_id)
        @mutex.synchronize {
          job = get_job(queue_name, job_id)
          if job
            job.status = FAILED
            job.attempts += 1

            if job.attempts == @max_retries
              @failed_jobs[queue_name].push(job)
              @jobs[queue_name].delete(job)
              @logger.warn("[MemoryStore] job: '#{job.job_name}' has failed the reached the maximum amount of retries (#{@max_retries}) and is being removed from the queue.")
            else
              @logger.info("[MemoryStore] failed job: '#{job.job_name}' has been requeued and attempted #{job.attempts} times")
            end
          end
        }
      end

    end
  end
end
