Rabotnegi.helpers do
  def quick_route(*args)
    case 
      when Vacancy === args.first then "/vacancies/#{args.first.to_param}"
      else nil
    end
  end

  def absolute_url(*args)
    "#{request.scheme}://#{request.host_with_port}#{url(*args)}"
  end

  # # (vacancy) => quick_route
  # # (user) => polymorphic
  # # (:user, user) => polymorphic
  # # (:edit, :user, user) => helper
  # def url(*args)
  #   result = quick_route(*args)
  #   return result if result
  # 
  #   if ApplicationModel === args.first || Symbol === args.first && ApplicationModel === args.second
  #     polymorphic_path(args)
  #   else
  #     send("#{args.shift}_path", *args)
  #   end
  # end
  

  # 
  # Current user
  # 

  def current_user
    return @current_user if defined? @current_user
  
    @current_user = if request.cookies[:uid].present?
      User.where(_id: Encryptor.decrypt(request.cookies[:uid])).first
    else
      User.where(agent: request.user_agent, ip: request.ip).first
    end
  
    response.delete_cookie :uid if @current_user == nil
  
    @current_user
  
  rescue => e
    logger.error "!!! Controller.current_user: #{e.class} #{e.message}"
    response.delete_cookie :uid
    nil
  end
  
  def current_user=(user)
    @current_user = user
    response.set_cookie :uid, Encryptor.encrypt(user.id), expires: 2.years.from_now
  end

  def current_user!
    self.current_user ||= bot? ? User.new : User.create!(agent: request.user_agent, ip: request.ip)
  end

  # 
  # Mongo sorting
  # 
  
  def decode_order_to_mongo(param = params[:sort])
    SortExpressions.decode_order_to_mongo(param)
  end  

  def encode_order(field, reverse_by_default = false, param = params[:sort])
    SortExpressions.encode_order(field, params, reverse_by_default)
  end
  
  # 
  # Authentication
  # 
  
  # def authenticate_or_request_with_http_basic(realm = 'Application')
  #   authenticate_with_http_basic || request_http_basic_authentication(realm)
  # end
  # 
  # def authenticate_with_http_basic
  #   if auth_str = request.env['HTTP_AUTHORIZATION']
  #     return 'login:password' == ActiveSupport::Base64.decode64(auth_str.sub(/^Basic\s+/, ''))
  #   end
  # end
  # 
  # def request_http_basic_authentication(realm = 'Application')
  #   response.headers["WWW-Authenticate"] = %(Basic realm="#{realm}")
  #   response.body = "HTTP Basic: Access denied.\n"
  #   response.status = 401
  #   return false
  # end

  def admin_required
    # auth_result = Rack::Auth::Basic.new(self) do |login, password|
    #   login == "admin" && password == "0000"
    # end.call(request.env)
    # throw :halt, auth_result if auth_result.first == 401
    
    throw :halt, 401, {"WWW-Authenticate" => %(Basic realm="Restricted Area")}, "" unless authorized?

    # self.admin = Admin.log_in('root', '0000') and return if Mu.env.test?
    # return true if Mu.env.development?
    # authenticate_or_request_with_http_basic { |login, password| login == Se.admin_login && password == Se.admin_password }
  end

  def authorized?
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['admin', '0000']
  end
    
  # 
  # Helpers
  # 
  def bot?
    request.user_agent =~ /Googlebot|YandexBot|Deepnet|Nigma|bingbot|stat.cctld.ru/
    false
  end  
  
  # include SimpleCaptcha::ControllerHelpers
  # include ControllerHelper
  # include EventLog::Accessor
  # 
  # # rescue_from(ActiveRecord::RecordInvalid) { render :form, :status => 422 }
  # # rescue_from(ActiveRecord::RecordNotFound) { |e|
  # #   flash[:error] = "К сожалению, то что вы искали, мы уже куда-то похерили. Если оно вообще здесь было."
  # #   redirect_to '/'
  # # }
  # 
  # class InvalidCaptcha < StandardError
  #   attr :template
  #   def initialize(template)
  #     @template = template
  #   end
  # end
  # 
  # rescue_from Exception, :with => :handle_unexpected_exception
  # rescue_from InvalidCaptcha do |error|
  #   render error.template, status: 422 if error.template
  # end
  # 
  # helper :all
  # before_filter :set_locale
  # 
  # delegate :benchmark, :to => ActionController::Base
  # 
  # protect_from_forgery
  # 
  # Encryptor = ActiveSupport::MessageEncryptor.new(Rabotnegi::Application.config.secret_token)
  # 
  # before_filter do
  #   logger.debug "  Session: #{session.inspect}"
  # end if Mu.env.development?
  # 
  # ADMIN_CONTROLLERS = %w(AdminController AdminItemsController)
  # before_filter do
  #   if request.subdomain == "admin" && !ADMIN_CONTROLLERS.include?(self.class.name)
  #     raise ActionController::RoutingError, "No route matches #{request.path} on the admin subdomain"
  #   end
  # end
  # 
  # protected
  # 
  # def ensure_proper_protocol
  #   Mu.env.development? || Mu.env.test? || super
  # end
  # 
  # def set_locale
  #   I18n.locale = 'ru'
  # end
  # 
  # def employer_required
  #   current_employer || redirect_to(employer_path)
  # end
  # 
  # 
  # def resume_required
  #   current_resume || redirect_to(worker_login_path)
  # end
  # 
  # def current_employer
  #   return @current_employer if defined? @current_employer
  #   @current_employer = session[:employer_id] ? Employer.get(session[:employer_id]) : nil
  # end
  # helper_method :current_employer
  # 
  # def current_resume
  #   return @current_resume if defined? @current_resume
  #   resume_id = session[:resume_id] || cookies[:resume_id]
  #   if @current_resume = resume_id ? Resume.get(resume_id) : nil
  #     session[:resume_id] = @current_resume.id
  #     cookies[:resume_id] = @current_resume.id
  #   else
  #     session[:resume_id] = nil
  #     cookies.delete(:resume_id)
  #   end
  #   @current_resume
  # end

  # 
  # def find_model
  #   selector = model_class.respond_to?(:get) ? :get : :find
  #   @model = model_class.send(selector, params[:id])
  # end
  # 
  # def update_model(model, attributes, url)
  #   model.attributes = attributes
  #   if model.save
  #     redirect_to url, notice: "Изменения сохранены"
  #   else
  #     render :edit
  #   end  
  # end
  
  # def self.model(model_class)
  #   const_set :Model, model_class
  #   define_method(:model_class) { model_class }
  #   define_method(:model_name) { model_class.model_name.element }
  #   define_method(:model_plural) { model_class.model_name.plural }    
  # end
  # 

  after do
    exception = env["sinatra.error"]
    Err.register(route && route.named || request.path, exception,
      params: params.except("captures"),
      url: request.url, 
      verb: request.request_method,
      session: session.to_hash.except('flash'),
      flash: flash.to_hash,
      request_headers: env.select { |k,v| k.starts_with?("HTTP_") },
      response_headers: headers
    ) if exception
    true
  end

  error 500..599 do |exception|
    # next if Mu.env.test? unless $test_error_reporting_enabled

    # Err.register(route.named || request.path, exception,
    #   params: params.except("captures"),
    #   url: request.url, 
    #   verb: request.request_method,
    #   session: session.to_hash.except('flash'),
    #   flash: flash.to_hash,
    #   request_headers: env.select { |k,v| k.starts_with?("HTTP_") },
    #   response_headers: headers
    # )
  end
  
  # 
  # def validate_captcha!(options = {})
  #   if !captcha_done? && !simple_captcha_valid?
  #     options[:model].errors.add(:captcha, "invalid") if options[:model]
  #     log.warn 'captcha_wrong', ip_adress: request.remote_ip, 
  #       actual_captcha: params[:captcha], expected_captcha: SimpleCaptcha::Utils::simple_captcha_value(session[:captcha])
  #     raise InvalidCaptcha.new(options[:template])
  #   else
  #     skip_captcha
  #   end    
  # end
  # 
  # def skip_captcha
  #   session["#{controller_name}_#{action_name}_captcha"] = true
  # end
  # 
  # def reset_captcha
  #   session.delete "#{controller_name}_#{action_name}_captcha"
  #   session.delete "captcha"
  # end
  # 
  # def captcha_done?
  #   return true if Mu.env.starts_with?("test")
  #   session["#{controller_name}_#{action_name}_captcha"]
  # end
  # helper_method :captcha_done?

  def __t(*args)
    puts "  TRACE - #{caller.first} #{args.inspect}" 
  end
  
end
