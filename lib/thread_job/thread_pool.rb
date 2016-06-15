require 'logger'

module ThreadJob
  class ThreadPool

    def initialize(max_size=5, logger=Logger.new(STDOUT))
      @queue = Queue.new
      @logger = logger
      @avail_pool = max_size.times.map do
        Thread.new do
          @logger.debug("[ThreadPool] started thread #{Thread.current}")
          while true
            monitor_queue
          end
        end
      end
      @use_pool = []
      @mutex = Mutex.new
    end

    def has_available_thread?
      @mutex.synchronize {
        @logger.debug("[ThreadPool] #{@avail_pool.length} threads available, #{@use_pool.length} threads in use")
        return @avail_pool.length > 0
      }
    end

    def monitor_queue
      work = @queue.pop
      if work
        @mutex.synchronize {
          @use_pool.push(Thread.current)
          @avail_pool.delete(Thread.current)
        }

        @logger.debug("[ThreadPool] Running job '#{work[:job_name]}' on thread #{Thread.current}")
        begin
          work[:job].run
        rescue => e
          @logger.error("[ThreadPool] Worker thread #{Thread.current} encountered an error #{e} while processing job '#{work[:job_name]}'")
          work[:job_store].failed_job(work[:queue_name], work[:id])
          @mutex.synchronize {
            @avail_pool.push(Thread.current)
            @use_pool.delete(Thread.current)
          }
          return
        end
        work[:job_store].complete_job(work[:queue_name], work[:id])

        @mutex.synchronize {
          @avail_pool.push(Thread.current)
          @use_pool.delete(Thread.current)
        }
      end
    end

    def run(job_hash)
      @queue.push(job_hash)
    end
  end
end
