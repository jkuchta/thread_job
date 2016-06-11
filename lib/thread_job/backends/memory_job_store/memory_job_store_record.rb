module ThreadJob
  class MemoryJobStoreRecord < JobStoreRecord
    attr_accessor :id, :job, :job_name, :queue_name, :status
  end
end
