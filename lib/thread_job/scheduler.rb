require 'logger'

module ThreadJob
  class Scheduler

    def initialize(queue_name, job_store=ThreadJob::Memory::Store.new, poll_delay_seconds=5, thread_pool_size=5, logger=Logger.new(STDOUT))
      @job_store = job_store
      @logger = logger
      @queue_name = queue_name
      @poll_delay = poll_delay_seconds
      @thread_pool = ThreadPool.new(thread_pool_size, logger)
    end

    def start
      return Thread.new do
        do_start
      end
    end

    def add_job(job_name, job)
      @logger.info("[Scheduler] Added job: '#{job_name}' to the '#{@queue_name}' queue")
      @job_store.save_job(@queue_name, job_name, job)
    end

    private
    def do_start
      @logger.info("[Scheduler] starting...")
      while true
        if @thread_pool.has_available_thread?
          job_hash = @job_store.poll_for_job(@queue_name)
          if job_hash
            job_hash[:queue_name] = @queue_name
            job_hash[:job_store] = @job_store
            @logger.info("[Scheduler] scheudled job '#{job_hash[:job_name]}', sending to thread pool")
            @thread_pool.run(job_hash)
          end
        end
        sleep(@poll_delay)
      end
    end

  end
end
