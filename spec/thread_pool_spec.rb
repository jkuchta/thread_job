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

end
