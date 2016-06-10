module ThreadJob
  class ThreadPool

    def initialize(max_size=5)
      @avail_pool = []
      @use_pool = []
      @mutex = Mutex.new
    end

    def run(&blk)
      # for now just run in one thread
      Thread.new do
        blk.call
      end
    end
  end
end
