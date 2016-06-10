require 'logger'

module ThreadJob
  class Scheduler
    attr_accessor :logger

    def initialize(queue_name, job_store, sleep_delay=5, thread_pool_size=5)
      @queue_name = queue_name
      @job_store = job_store
      @logger = Logger.new(STDOUT)
      @mutex = Mutex.new
      @sleep_delay = sleep_delay
      @thread_pool = ThreadPool.new(thread_pool_size)
    end

    def start
      return Thread.new do
        do_start
      end
    end

    def add_job(job_name, job)
      @logger.info "Added job: #{job_name} to the queue"
      @job_store.save_job(@queue_name, job_name, job)
    end

    private
    def do_start
      @logger.info 'Scheduler starting...'
      while true do
        job_hash = get_available_job
        if job_hash
          @thread_pool.run do
            @logger.info "Running job name: #{job_hash[:job_name]}, id: #{job_hash[:id]}"
            job_hash[:job].run
            @logger.info "Completed job name: #{job_hash[:job_name]}, id: #{job_hash[:id]}"
            @job_store.complete_job(@queue_name, job_hash[:id])
          end
        end
        sleep(@sleep_delay)
      end
    end

    def get_available_job
      job_hash = @job_store.poll_for_job(@queue_name)
    end

  end
end
