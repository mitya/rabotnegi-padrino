module Rabotaru
  class Job < Gore::ApplicationModel
    field :state, type: Symbol, default: 'pending'
    field :cities, type: Array
    field :industries, type: Array
    field :run_count, type: Integer
    field :error, type: String
    field :results, type: Hash
    embeds_many :loadings, class_name: 'Rabotaru::Loading'
    def_state_predicates 'state', :pending, :started, :failed, :loaded, :processed, :cleaned
    store_in "rabotaru.jobs"
    identity type: String
    
    attr_accessor :period, :queue, :current

    before_create do 
      self.id = Time.now.strftime("%Y%m%d-%H%M%S-%6N") 
      self.cities ||= City.all.pluck(:key)
      self.industries ||= Industry.all.pluck(:key)
    end

    def run
      @period ||= Se.rabotaru_period
      @queue ||= cities.product(industries).map { |city, industry| Loading.new(city: city, industry: industry) }
      @current = queue.shift

      mark :started, run_count: run_count.to_i + 1

      trap('INT') do
        reload
        mark :failed, error: "Received INT signal" if started? || pending?
        exit
      end

      loop { done = tick; break if done }
      
    rescue => e
      Gore::Err.register("Rabotaru::Job.run", e, params: {job_id: id})
      mark :failed, error: Gore.format_error(e)
    end
    
    def rerun
      @queue = loadings_to_retry
      run
    end
    
    def postprocess
      processor = Processor.new(id)
      processor.add_event_handler(:filtered) { |data| store(results: data) }
      processor.process
      mark :processed
      
      VacancyCleaner.clean_all(started_at)
      mark :cleaned
      
    rescue => e
      Gore::Err.register("Rabotaru::Job.postprocess", e, params: {job_id: id})
      mark :failed, error: Gore.format_error(e)
    end
    
    def to_s
      "RabotaruJob(#{id})"
    end

    private

    def loadings_to_retry
      pending_items = cities.product(industries) - loadings.map_to_array(:city, :industry)
      pending_loadings = pending_items.map { |city, industry| Loading.new(city: city, industry: industry) }
      
      non_done_loadings = loadings.select_neq(state: :done)
      non_done_loadings.send_each(:mark, :pending)
      
      pending_loadings.concat(non_done_loadings)
      pending_loadings.sort_by! { |loading| loading.new? ? 1 : 0 }
      pending_loadings
    end
  
    def tick
      reload
      current.reload if current && (current.queued? || current.started?)
      log.debug 'tick', current: current.inspect, loadings_count: loadings.count
      case current.try(:state)
      when nil
        mark :loaded
        Gore.enqueue(Rabotaru::Job, :postprocess, id)
        return true
      when :pending
        loadings << current unless loadings.include?(current)
        current.queue
        wait
      when :started, :queued
        wait
        if Time.now - current.changed_at > 20.minutes
          current.mark :failed, error: "Skipped after timeout"
          @current = queue.shift
        end
      when :failed
        if loadings.select(&:failed?).count > 3
          mark :failed
          return true
        end
        @current = queue.shift
      when :done
        time_since_done = Time.now - current.done_at
        @current = queue.shift
        wait(period - time_since_done) if time_since_done < period && period - time_since_done > 1
      end
      
      false
    end

    def wait(timeout = period)
      sleep(timeout)
    end

    def self.postprocess(job_id)
      find(job_id).postprocess
    end
  end
end
