module Gore::ControllerHelpers
  module Urls
    def absolute_url(*args)
      uri url(*args)
    end

    def current_url(params = {})
      current_path(params.stringify_keys)
    end

    def asset_path(kind, source)
      return source if source =~ /^http/
      asset = settings.assets.find_asset(source)
      return nil unless asset
      "/rabotnegi/assets/" + asset.digest_path
    end
  
    def decode_order_to_mongo(param = params[:sort])
      Gore::SortExpressions.decode_order_to_mongo(param)
    end  

    def encode_order(field, reverse_by_default = false, param = params[:sort])
      Gore::SortExpressions.encode_order(field, params, reverse_by_default)
    end    
  end
  
  module Identification
    # (vacancy#1234) => "v-2134"
    def web_id_for_record(record)
      return nil unless record
      [web_prefix_for_class(record.class), record.id].join("-")
    end
  
    # (Vacancy) => "v"
    # (User) => "user"  
    def web_prefix_for_class(klass)
      case klass
        when Vacancy then "v"
        else ActiveModel::Naming.singular(record)
      end    
    end
  
    # (vacancy#1234) => "v-1234"
    # (:edit, vacancy#1234, :custom) => "edit-v-1234-custom"
    def web_id(*args)
      args.map { |x| x.respond_to?(:to_key) ? web_id_for_record(x) : x }.join("-")
    end    
  end  
  
  module Users
    def current_user
      return @current_user if defined? @current_user
      @current_user = find_user_by_cookie || find_user_by_ip || create_new_user
      store_user_cookie unless request.cookies['uid']
      @current_user
    end  
  
    def find_user_by_cookie
      return nil unless request.cookies['uid']
      user_id = settings.message_encryptor.decrypt_and_verify(request.cookies['uid'])
      User.find(user_id)
    rescue
      response.delete_cookie 'uid'
      nil
    end
    
    def find_user_by_ip
      User.where(agent: request.user_agent, ip: request.ip).first
    end
    
    def create_new_user
      bot? ? User.new : User.create!(agent: request.user_agent, ip: request.ip)
    end
    
    def store_user_cookie
      user_token = settings.message_encryptor.encrypt_and_sign(@current_user.id)
      response.set_cookie 'uid', value: user_token, path: request.script_name, expires: 2.years.from_now            
    end

    #
    # Authentication
    # 
  
    def admin_required
      return if Gore.env.development?
      halt 401, {"WWW-Authenticate" => %(Basic realm="Restricted Area")}, "" unless authorized?
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
end
