# -*- encoding: utf-8 -*-

Gem::Specification.new do |spec|
  spec.authors        = ['Jeff Kuchta']
  spec.description    = 'A simple framework to asynchronously execute longer running tasks in the background using threads.'
  spec.email          = ['jeff@flywiremedia.com']
  spec.files          = %w[thread_job.gemspec]
  spec.files          += Dir.glob('{lib}/**/*')
  spec.homepage       = 'https://github.com/jkuchta/thread_job'
  spec.licenses       = ['MIT']
  spec.name           = 'thread_job'
  spec.require_paths  = ['lib']
  spec.summary        = 'Lightweight asynchronous scheduler and workers'
  #spec.test_files     = Dir.glob('spec/**/*')
  spec.add_development_dependency 'rspec'
  spec.version        = '0.1.0'
end
