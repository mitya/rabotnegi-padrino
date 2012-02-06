Rabotnegi.helpers do
  #
  # Current user
  # 
  
  def current_user
    return @current_user if defined? @current_user
  
    @current_user = if request.cookies['uid'].present?
      User.find(settings.message_encryptor.decrypt(request.cookies['uid'])) rescue nil
    else
      User.where(agent: request.user_agent, ip: request.ip).first
    end
  
    response.delete_cookie 'uid' if @current_user == nil
  
    @current_user
  
  rescue => e
    logger.error "!!! Controller.current_user: #{e.class} #{e.message}"
    response.delete_cookie 'uid'
    nil
  end
  
  def current_user=(user)
    @current_user = user
    response.set_cookie 'uid', value: settings.message_encryptor.encrypt(user.id), expires: 2.years.from_now
  end

  def current_user!
    self.current_user ||= bot? ? User.new : User.create!(agent: request.user_agent, ip: request.ip)
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
  # Other
  # 

  def bot?
    false # request.user_agent =~ /Googlebot|YandexBot|Deepnet|Nigma|bingbot|stat.cctld.ru/
  end  

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

end