# README #

ThreadJob
============
ThreadJob provides asynchronous scheduling and executing of tasks (longer) in the background using a thread pool. This can be distributed depending on the backend used.

Installation
============
If you'd like to use thread_job with the built-in memory store add `thread_job` to your `Gemfile`.
```ruby
gem 'thread_job'
```

If you'd like to use thread_job with Active Record, add `thread_job_active_record` to your `Gemfile`.

```ruby
gem 'thread_job_active_record'
```

Run `bundle install` to install the gems.

The Active Record backend requires a thread_jobs table. You can create that table by
running the following command:

    rails generate thread_job:active_record
    rake db:migrate

Rails 4.x
=========
TODO: Add some documentation here

Scheduling Jobs
============
## Basic Example
```ruby
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
scheduler = ThreadJob::Scheduler.new("default", backend, 2, 8, log)

job = ExampleJob.new
scheduler.add_job("First job", job)

# Start scheduling jobs
scheduler.start

# Add a job while scheduler is running
scheduler.add_job("Second job", job)
```