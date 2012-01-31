module Rabotaru
  class Loading
    include Mongoid::Document
        
    field :city, type: Symbol
    field :industry, type: Symbol
    field :state, type: Symbol, default: 'pending'
    field :error, type: String
    field :fail_count, type: Integer
    key :city, :industry

    embedded_in :job, class_name: 'Rabotaru::Job'
    validates_presence_of :city, :industry
    def_state_predicates 'state', :pending, :queued, :started, :done, :skipped, :failed
    
    def queue
      mark :queued
      Mu.enqueue(Rabotaru::Loading, :run, job.id, id)
    end

    def run
      mark :started
      loader = Loader.new(city, industry, job.id)
      loader.load
      mark :done
    rescue => e
      Err.register("Rabotaru::Loading.run", e, params: {city: city, industry: industry})
      mark :failed, error: Mu.format_error(e), fail_count: fail_count.to_i + 1
    end
    
    def changed_at
      self.class._states.map { |state| send("#{state}_at") }.compact.max
    end
    
    def inspect(*args)
      Mu.inspection(self, [city, industry], state)
    end
    
    def to_s
      inspect
    end
    
    def self.run(job_id, loading_id)
      job = Job.find(job_id)
      loading = job.loadings.find(loading_id)
      loading.run
    end
  end
end
