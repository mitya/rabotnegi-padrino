Rabotnegi.helpers do
  #
  # Current user
  # 
  
  def current_user
    return @current_user if defined? @current_user
  
    @current_user = if request.cookies[:uid].present?
      encryptor = ActiveSupport::MessageEncryptor.new(settings.uid_secret_token)
      User.where(_id: encryptor.decrypt(request.cookies[:uid])).first
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
    encryptor = ActiveSupport::MessageEncryptor.new(settings.uid_secret_token)
    response.set_cookie :uid, value: encryptor.encrypt(user.id), expires: 2.years.from_now
  end

  def current_user!
    self.current_user ||= bot? ? User.new : User.create!(agent: request.user_agent, ip: request.ip)
  end

  # 
  # Mongo sorting
  # 
  
  def decode_order_to_mongo(param = params[:sort])
    Gore::SortExpressions.decode_order_to_mongo(param)
  end  

  def encode_order(field, reverse_by_default = false, param = params[:sort])
    Gore::SortExpressions.encode_order(field, params, reverse_by_default)
  end
  
  #
  # Authentication
  # 
  
  def admin_required
    # self.admin = Admin.log_in('root', '0000') and return if Gore.env.test?
    return if Gore.env.development?
    throw :halt, 401, {"WWW-Authenticate" => %(Basic realm="Restricted Area")}, "" unless authorized?
  end

  def authorized?
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['admin', '0000']
  end
    
  #
  # Helpers
  # 
  
  def absolute_url(*args)
    uri url(*args)
  end
    
  def bot?
    false # request.user_agent =~ /Googlebot|YandexBot|Deepnet|Nigma|bingbot|stat.cctld.ru/
  end  
  
  #
  # Overrides
  #
     
  def dump_errors!(boom)
    return unless Gore.env.development?
    return unless Array === boom.backtrace

    boom.backtrace.reject! { |line| line =~ /thin|thor|eventmachine|rack|barista|http_router/ }
    boom.backtrace.map! { |line| line.gsub(Padrino.root, '/$PADRINO_ROOT') }
    super
  end
  
  # 
  # Filters & error handlers
  # 

  error 500..599 do
    Gore::Err.register route.named || request.path, env["sinatra.error"],
      params: params.except("captures"),
      url: request.url, 
      verb: request.request_method,
      session: session.to_hash.except('flash'),
      flash: flash.to_hash,
      request_headers: env.select { |k,v| k.starts_with?("HTTP_") },
      response_headers: headers
        
    raise env["sinatra.error"]
  end
  
  before { settings.set :last_instance, self } if Gore.env.test?
    
  # def employer_required
  #   current_employer || redirect(employer_path)
  # end
  # 
  # def resume_required
  #   current_resume || redirect_to(worker_login_path)
  # end
  # 
  # def current_employer
  #   return @current_employer if defined? @current_employer
  #   @current_employer = session[:employer_id] ? Employer.get(session[:employer_id]) : nil
  # end
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
  
  # class InvalidCaptcha < StandardError
  #   attr :template
  #   def initialize(template)
  #     @template = template
  #   end
  # end
  # 
  # rescue_from InvalidCaptcha do |error|
  #   render error.template, status: 422 if error.template
  # end
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
  #   return true if Gore.env.starts_with?("test")
  #   session["#{controller_name}_#{action_name}_captcha"]
  # end
end
