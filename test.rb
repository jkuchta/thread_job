require 'thread_job'
Thread.abort_on_exception = true
scheduler = ThreadJob::Scheduler.new("default", ThreadJob::MemoryJobStore.new, 2, 2)


class ExampleJob < ThreadJob::Job
  def run
    puts 'hello world about to sleep for 10'
    sleep(10)
    puts 'done sleeping'
  end
end

x = ExampleJob.new
scheduler.add_job("Example", x)
scheduler.add_job("Example2", x)
scheduler.start

# TODO need to add ability for scheduler to add job after it has been started
scheduler.add_job("Example3", x)
scheduler.add_job("Jeff test again", x)
while true
  sleep 5
end

