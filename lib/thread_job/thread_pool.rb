require 'logger'

module ThreadJob
  class ThreadPool

    def initialize(max_size=5)
      @queue = Queue.new
      @logger = Logger.new(STDOUT)
      @avail_pool = max_size.times.map do
        Thread.new do
          @logger.info("[ThreadPool] started thread #{Thread.current}")
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
        @logger.info("[ThreadPool] #{@avail_pool.length} threads available, #{@use_pool.length} threads in use")
        return @avail_pool.length > 0
      }
    end

    def monitor_queue
      blk = @queue.pop
      if blk
        @mutex.synchronize {
          @use_pool.push(Thread.current)
          @avail_pool.delete(Thread.current)
        }

        @logger.info("[ThreadPool] Running job on thread #{Thread.current}")
        blk.call
        @logger.info("[ThreadPool] Completed job on thread #{Thread.current}")

        @mutex.synchronize {
          @avail_pool.push(Thread.current)
          @use_pool.delete(Thread.current)
        }
      end
    end

    def run(&blk)
      @queue.push(blk)
    end
  end
end
