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
    it 'does not raise an expection' do
      scheduler = ThreadJob::Scheduler.new("default")

      class ExJob < ThreadJob::Job
        def run
          puts "hello"
        end
      end

      job = ExJob.new
      scheduler.add_job("Example Job", job)
    end
  end

  describe '#start' do
    it 'starts new thread' do
      scheduler = ThreadJob::Scheduler.new("default")
      expect(scheduler.start.class).to eq(Thread)
    end
  end
end
