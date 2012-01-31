class Err < ApplicationModel
  field :source
  field :host
  field :params, type: Hash
  field :exception_class
  field :exception_message
  field :backtrace

  field :controller
  field :action

  field :url
  field :verb
  field :session, type: Hash
  field :cookies, type: Hash
  field :request_headers, type: Hash
  field :response_headers, type: Hash

  index :created_at

  validates_presence_of :exception_class
  
  scope :recent, ->(since = 1.hour.ago) { where(:created_at.gte => since) }

  def source
    self[:source] || "#{controller}/#{action}"
  end

  def notify
    ErrMailer.notification(self).deliver unless Mu.env.development?
  end

  def to_s
    "#{source} - #{exception_class} - #{exception_message.to_s.truncate(40)}"
  end

  class << self
    def register(source, exception, data = {})
      Log.error "!!! #{exception.class}: #{exception.message}"
      
      data.update(
        source: source,
        host: Socket.gethostname, 
        time: Time.now,
        exception_class: exception.class.name,
        exception_message: exception.message,
        backtrace: exception.backtrace.join("\n")
      )
      
      err = create!(data)
      # err.notify if recent.count < Se.err_max_notifications_per_hour
      err
            
    rescue => e
      puts "!!! (ERROR IN ERROR LOGGING) #{e.class}: #{e.message}"
      puts e.backtrace.join("\n")
    end
    
    def query(params)
      params = params.symbolize_keys
      params.assert_valid_keys(:q)
      query = Regexp.new(params[:q] || "", true)

      scope = self
      scope = scope.any_of({exception_class: query}, {exception_message: query}, {url: query}) if params[:q].present?
      scope
    end    
  end
end
