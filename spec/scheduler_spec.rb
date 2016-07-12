describe ThreadJob::Scheduler do
  before do
    suppress_log_output
  end

  describe '#new' do
    it 'should raise ArgumentError when missing required queue_name' do
      expect { ThreadJob::Scheduler.new }.to raise_exception(ArgumentError)
    end
  end

  describe '#add_job' do
    context 'when scheduler has not started' do
      let(:scheduler) { ThreadJob::Scheduler.new('default') }

      it 'adds a job to the job_store' do
        class ExJob < ThreadJob::Job
          def run
            puts "hello"
          end
        end

        job = ExJob.new
        scheduler.add_job("Example Job", job)
        store = scheduler.instance_variable_get(:@job_store)
        job_queue = store.instance_variable_get(:@jobs)['default']
        expect(job_queue.length).to equal(1)
      end
    end

    # Use zero workers so that items are not being removed from queue in test
    context 'when scheduler has started but has no workers in thread pool' do
      let(:scheduler) { ThreadJob::Scheduler.new('default', ThreadJob::Memory::Store.new, 2, 0) }
      before { scheduler.start }

      it 'adds a job to the job_store' do
        class ExJob < ThreadJob::Job
          def run
            puts "hello"
          end
        end

        job = ExJob.new
        scheduler.add_job("Example Job", job)
        scheduler.add_job("Example Job 2", job)
        store = scheduler.instance_variable_get(:@job_store)
        job_queue = store.instance_variable_get(:@jobs)['default']
        expect(job_queue.length).to equal(2)
      end
    end
  end

  describe '#start' do
    it 'starts new thread' do
      scheduler = ThreadJob::Scheduler.new("default")
      expect(scheduler.start.class).to eq(Thread)
    end
  end

  describe '#kill' do
    context 'when scheduler is running' do
      let(:scheduler) { ThreadJob::Scheduler.new('default', ThreadJob::Memory::Store.new, 2, 0) }
      before { scheduler.start }
      it 'stops the thread' do
        expect(scheduler.instance_variable_get(:@scheduler_thread)).to receive(:kill)
        scheduler.kill
      end
    end
  end
end
