MongoReflector.define_metadata do
  desc Vacancy do
    list :industry, :city, [:title, :link, trim: 50], [:employer_name, trim: 40], :created_at, :updated_at, :loaded_at
    list_order [:updated_at, :desc]
    view :id, :title, :city, :industry, :external_id, :employer_name, :created_at, :updated_at, :loaded_at, :cleaned_at, :salary, :description, :poster_ip
    edit title: 'text',
      city_name: ['combo', City.all], industry_name: ['combo', Industry.all],
      external_id: 'text',
      employer_id: 'text', employer_name: 'text',
      created_at: 'date_time', updated_at: 'date_time',
      description: 'text_area'
  end    

  desc User do
    list :industry, :city, [:ip, :link], [:agent, trim: 100], :created_at
  end

  desc Err do
    list created_at: _, source: :link, 
      url: [trim: 60],
      exception: [ ->(err) { "#{err.exception_class}: #{err.exception_message}" }, trim: 100 ]
    view id: _, created_at: _, host: _, source: _, 
      url: ->(err) { "#{err.verb} #{err.url}" },
      exception_class: _,
      exception_message: _,
      params: 'hash_view',
      session: 'hash_view', request_headers: 'hash_view', response_headers: 'hash_view', backtrace: :pre
    actions update: false, delete: false
  end

  desc EventLog::Item, 'event_log_items' do
    list :created_at, :severity, :source, [:event, 'stringify', link: true], [:data, 'inline_multi_view']
    view :id, :created_at, :severity, :source, :event, [:data, 'multi_view'], [:extra, 'hash_view']
    actions update: false, delete: false
  end
  
  desc Rabotaru::Job, 'rabotaru_jobs' do
    list [:id, :link], :state, :created_at, :updated_at, :started_at, :loaded_at, :processed_at, :cleaned_at, :failed_at
    list_css_classes { |x| { processed: x.cleaned?, failed: x.failed? } }
    view :id, :state, :created_at, :updated_at, :started_at, :loaded_at, :processed_at, :cleaned_at, :failed_at, 
      "loadings.count", [:error, 'html_escape'], :run_count, [:cities, 'array_inline'], [:industries, 'array_inline'], [:results, 'hash_of_lines']
    view_subcollection :loadings, 'rabotaru_loadings'
    actions update: false, delete: false
  end

  desc Rabotaru::Loading, 'rabotaru_loadings' do
    list :id, :city, :industry, :state, :error, :changed_at
    view :id, :state, :created_at, :changed_at
    actions update: false, delete: false
  end    
end
