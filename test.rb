require 'thread_job'
scheduler = ThreadJob::Scheduler.new("default", ThreadJob::MemoryJobStore.new)


class ExampleJob < ThreadJob::Job
  def run
    puts 'hello world'
  end
end

x = ExampleJob.new
scheduler.add_job("Example", x)
scheduler.add_job("Example2", x)
scheduler.start

while true
  sleep 5
end

# TODO need to add ability for scheduler to add job after it has been started
scheduler.add_job("Example2", x)
scheduler.add_job("Jeff test again", x)
