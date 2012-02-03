class Rabotaru::Processor
  attr_accessor :vacancies, :work_dir

  include Gore::EventLog::Accessor
  include Gore::EventHandling
  
  def initialize(key = Gore.date_stamp)
    @vacancies = []
    @work_dir = Rabotnegi.config.rabotaru_dir.join(key)
    @converter = Rabotaru::Converter.new
  end

  def process
    log.info "start"

    read unless vacancies.any?
    remove_duplicates
    filter
    save

    log.info "done"
  end

  def read
    Pathname.glob(@work_dir.join "*.json").each do |file|
      data = file.read.sub!(/;\s*$/, '')
      items = Gore.json.decode(data)
      vacancies = items.map { |item| convert(item) }.compact
      @vacancies.concat(vacancies)
    end
    log.info "read", count: @vacancies.size
  end

  def remove_duplicates
    @vacancies.uniq_by! { |v| v.external_id }
    log.info "remove_duplicates", keep: @vacancies.size
  end
  
  def filter
    new_vacancies, updated_vacancies = [], []
    loaded_external_ids = @vacancies.pluck(:external_id)
    existed_vacancies = Vacancy.where(:external_id.in => loaded_external_ids)
    existed_vacancies_map = existed_vacancies.index_by(&:external_id)

    @vacancies.each do |loaded_vacancy|
      if existed_vacancy = existed_vacancies_map[loaded_vacancy.external_id]
        if existed_vacancy.created_at != loaded_vacancy.created_at
          existed_vacancy.attributes = loaded_vacancy.attributes.except('_id')
          updated_vacancies << existed_vacancy
        end        
      else
        new_vacancies << loaded_vacancy
      end
    end

    now = Time.now
    new_vacancies.each { |v| v.loaded_at = now }

    @vacancies = new_vacancies + updated_vacancies

    raise_event :filtered do
      detalization = @vacancies.each_with_object({}) { |v, memo|
        key = "#{v.city}-#{v.industry}" 
        memo[key] = memo[key].to_i + 1
      }
    
      { filter: {created: new_vacancies.count, updated: updated_vacancies.count, total: @vacancies.count}, details: detalization }
    end
  end

  def save
    @vacancies.send_each(:save!)
  end
  
  def convert(item)
    @converter.convert(item)
  rescue => e
    log.warn "convert.fail", reason: Gore.format_error(e), item: item['position']
    nil
  end  
end
