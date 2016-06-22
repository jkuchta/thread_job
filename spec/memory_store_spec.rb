describe ThreadJob::Memory::Store do
  before do
    suppress_log_output
  end

  describe '#save_job' do
    let(:store) { ThreadJob::Memory::Store.new }
    let(:job) { ThreadJob::Job.new }

    it 'adds a job to the queue' do
      store.save_job('default', 'test job', job)
      expect(store.instance_variable_get(:@jobs)['default'].length).to equal(1)
    end
  end

  describe '#get_job' do
    context 'when queue is empty' do
      let(:store) { ThreadJob::Memory::Store.new }

      it 'returns nil' do
        j = store.get_job('any', 1)
        expect(j).to be_nil
      end

      it 'logs a warning' do
        logger = store.instance_variable_get(:@logger)
        expect(logger).to receive(:warn).with("[MemoryStore] unable to get job: 1 from queue: test")
        store.get_job('test', 1)
      end
    end

    context 'when queue has 1 job in it' do
      let(:store) { ThreadJob::Memory::Store.new }
      let(:job) { ThreadJob::Job.new }
      before { store.save_job('default', 'test job', job) }

      it 'returns a job when using valid id' do
        job_id = store.instance_variable_get(:@jobs)['default'].first.id
        j = store.get_job('default', job_id)
        expect(j.job_name).to eq('test job')
      end

      it 'returns nil when using invalid id' do
        j = store.get_job('default', -1)
        expect(j).to be_nil
      end
    end
  end

  describe '#poll_for_job' do
    context 'when queue is empty' do
      let(:store) { ThreadJob::Memory::Store.new }

      it 'returns nil' do
        result = store.poll_for_job('default')
        expect(result).to be_nil
      end
    end

    context 'when queue has 1 job in it' do
      let(:store) { ThreadJob::Memory::Store.new }
      let(:job) { ThreadJob::Job.new }
      before { store.save_job('default', 'test job', job) }

      it 'retreives a job' do
        result = store.poll_for_job('default')
        expect(result[:job_name]).to eq('test job')
      end
    end
  end

  describe '#complete_job' do
    context 'when queue has 1 job in it' do
      let(:store) { ThreadJob::Memory::Store.new }
      let(:job) { ThreadJob::Job.new }
      before { store.save_job('default', 'test job', job) }

      it 'removes 1 job from the queue' do
        job_id = store.instance_variable_get(:@jobs)['default'].first.id
        store.complete_job('default', job_id)
        expect(store.instance_variable_get(:@jobs)['default'].length).to equal(0)
      end
    end
  end

  describe '#fail_job' do
    context 'when queue has 1 job in it' do
      let(:store) { ThreadJob::Memory::Store.new }
      let(:job) { ThreadJob::Job.new }
      before { store.save_job('default', 'test job', job) }

      it 'sets job status as failed' do
        job_id = store.instance_variable_get(:@jobs)['default'].first.id
        store.fail_job('default', job_id)
        j = store.get_job('default', job_id)
        expect(j.status).to eq(ThreadJob::Memory::FAILED)
      end

      it 'increments attempts by 1' do
        job_id = store.instance_variable_get(:@jobs)['default'].first.id
        store.fail_job('default', job_id)
        j = store.get_job('default', job_id)
        expect(j.attempts).to equal(1)
      end

      it 'removes job from queue when max attempts reached' do
        job_id = store.instance_variable_get(:@jobs)['default'].first.id
        j = store.get_job('default', job_id)

        # Set current attempts to 1 less than max
        j.attempts = store.instance_variable_get(:@max_retries) - 1

        store.fail_job('default', job_id)
        j = store.get_job('default', job_id)
        expect(j).to be_nil
      end

      it 'adds job to list of failed jobs when max attempts reached' do
        job_id = store.instance_variable_get(:@jobs)['default'].first.id
        j = store.get_job('default', job_id)

        # Set current attempts to 1 less than max
        j.attempts = store.instance_variable_get(:@max_retries) - 1

        store.fail_job('default', job_id)
        failed_jobs = store.instance_variable_get(:@failed_jobs)
        expect(failed_jobs['default'].length).to equal(1)
      end

    end
  end
end
