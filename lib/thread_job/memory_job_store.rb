require 'logger'

module ThreadJob
  class MemoryJobStore < JobStore
    def initialize
      @available_jobs = {}
      @mutex = Mutex.new
      @logger = Logger.new(STDOUT)
    end

    def save_job(queue_name, job_name, job)
      @mutex.synchronize {
        queued_jobs = @available_jobs[queue_name] ||= []
        job_rec = ThreadJob::MemoryJobStoreRecord.new
        job_rec.job_name = job_name
        job_rec.job = job
        job_rec.queue_name = queue_name
        job_rec.id = queued_jobs.count
        queued_jobs.push(job_rec)
        @logger.info("Saved #{job_name} successfully")
      }
    end

    def poll_for_job(queue_name)
      @logger.info("Polling for jobs")
      @mutex.synchronize {
        job_record = @available_jobs[queue_name].first
        if job_record != nil
          @logger.info("Found job id #{job_record.id}, name #{job_record.job_name}")
          return {id: job_record.id, job: job_record.job, job_name: job_record.job_name}
        end
      }
    end

    def complete_job(queue_name, job_id)
      @mutex.synchronize {
        if @available_jobs[queue_name] != nil
          @available_jobs[queue_name].each do |job|
            if job.id == job_id
              @available_jobs[queue_name].delete(job)
            end
          end
        end
      }
    end
  end
end
