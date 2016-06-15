module ThreadJob
  class JobStore
    def save_job(queue_name, job_name, job)
    end

    def poll_for_job(queue_name)
    end

    def complete_job(queue_name, job_name)
    end

    def failed_job(queue_name, job_name)
    end
  end
end
