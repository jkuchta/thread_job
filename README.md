# README #

ThreadJob
============
ThreadJob provides asynchronous scheduling and executing of tasks (longer) in the background using a thread pool. In the future, this can be distributed depending on the backend used (once ActiveRecord Store is complete).

Installation
============
If you'd like to use thread_job with the built-in memory store add `thread_job` to your `Gemfile`.
```ruby
gem 'thread_job'
```

Run `bundle install` to install the gems.

Scheduling Jobs
============
## Basic Example
```ruby
require "thread_job"

# Jobs inherit from ThreadJob::Job and must implement a run method that is executed when the job is run
class ExampleJob < ThreadJob::Job
  def run
    puts "Output from example job"
  end
end

# Create a scheduler with a queue name 'test_queue_name' and some example jobs
scheduler = ThreadJob::Scheduler.new("test_queue_name")
job = ExampleJob.new
scheduler.add_job("First job", job)

# Start scheduling jobs
scheduler.start

# Add a job while scheduler is running
scheduler.add_job("Second job", job)

# Keep our example running
while true do
  puts "Just keeping our example alive..."
  sleep 5
end
```

## Parameters
### Scheduler
A scheduler requires a **queue_name** and optionally takes a **job store backend**, **poll delay** (in seconds), **worker thread pool size**, and **logger**
`ThreadJob::Scheduler.new(queue_name, job_store=ThreadJob::Memory::Store, poll_delay_seconds=5, thread_pool_size=5, logger=Logger.new(STDOUT))`

### Backend
A backend store optionally takes **max retries** (max number of times to attempt a job that is failing) and **logger**
`ThreadJob::Memory::Store.new(max_retries=10, logger=Logger.new(STDOUT))`

### Example with parameters
```ruby
require "thread_job"

# Jobs inherit from ThreadJob::Job and must implement a run method that is executed when the job is run
class ExampleJob < ThreadJob::Job
  def run
    puts "Output from example job"
  end
end

# Create a scheduler with a queue name 'test_queue_name' and some example jobs
logger = Logger.new(STDOUT)
logger.sev_threshold = Logger::INFO

# Create the custom backend with max of 3 retries
backend = ThreadJob::Memory::Store.new(3, logger)

# Create a scheduler using the customized backend, 2 second poll delay, and 8 worker threads
scheduler = ThreadJob::Scheduler.new("default", backend, 2, 8, logger)

job = ExampleJob.new
scheduler.add_job("First job", job)

# Start scheduling jobs
scheduler.start

# Add a job while scheduler is running
scheduler.add_job("Second job", job)

# Keep our example running
while true do
  puts "Just keeping our example alive..."
  sleep 5
end
```
