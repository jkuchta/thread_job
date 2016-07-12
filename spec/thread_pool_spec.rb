describe ThreadJob::ThreadPool do
  before do
    suppress_log_output
  end

  describe '#new' do
    it 'creates available threads' do
      pool = ThreadJob::ThreadPool.new(3)
      expect(pool.instance_variable_get(:@avail_pool).length).to equal(3)
    end
  end

  describe '#has_available_thread?' do
    context 'when threads are available' do
      let(:pool) { ThreadJob::ThreadPool.new }

      it 'returns true' do
        expect(pool.has_available_thread?).to be true
      end
    end

    context 'when threads are not available' do
      let(:pool) { ThreadJob::ThreadPool.new(0) }

      it 'returns false' do
        expect(pool.has_available_thread?).to be false
      end
    end
  end

  describe '#monitor_queue' do
    context 'when 3 items are being added to the queue' do
      let(:pool) { ThreadJob::ThreadPool.new }
      before do
        class ExampleJob < ThreadJob::Job
          def run
            work = 1 + 2 + 3
          end
        end

        queue = pool.instance_variable_get(:@queue)
        job = ExampleJob.new
        queue.push({ id: 1, job: job, job_name: 'Job 1' })
        queue.push({ id: 1, job: job, job_name: 'Job 1' })
        queue.push({ id: 1, job: job, job_name: 'Job 1' })
      end

      # This could be racey but as long as more threads than jobs it should be near instant
      it 'eventually empties the queue' do
        sleep 0.3
        queue = pool.instance_variable_get(:@queue)
        expect(queue).to be_empty
      end
    end
  end

  describe '#kill' do
    context 'when worker threads are available' do
      let(:pool) { ThreadJob::ThreadPool.new(5) }

      it 'kills all the threads' do
        threads = pool.instance_variable_get(:@avail_pool)
        threads.each do |thread|
          expect(thread).to receive(:kill)
        end
        pool.kill
      end
    end

    context 'when wokers are working and available' do
      let(:pool) { ThreadJob::ThreadPool.new(5) }
      before do
        class ExampleJob < ThreadJob::Job
          def run
            work = 1 + 2 + 3
          end
        end

        queue = pool.instance_variable_get(:@queue)
        job = ExampleJob.new
        200.times do
         queue.push({ id: 1, job: job, job_name: 'Job 1' })
        end
      end

      it 'kills all the threads' do
        avail_threads = pool.instance_variable_get(:@avail_pool)
        avail_threads.each do |avail_thread|
          expect(avail_thread).to receive(:kill)
        end

        used_threads = pool.instance_variable_get(:@use_pool)
        used_threads.each do |used_thread|
          expect(used_thread).to receive(:kill)
        end

        pool.kill
      end
    end
  end

  describe '#add_workers' do
    context 'when all threads are available' do
      let(:pool) { ThreadJob::ThreadPool.new(5) }

      it 'adds workers to the available pool' do
        num_avail_threads = pool.instance_variable_get(:@avail_pool).length
        pool.add_workers(5)
        expect(pool.instance_variable_get(:@avail_pool).length).to equal(num_avail_threads + 5)
      end
    end
  end
end
