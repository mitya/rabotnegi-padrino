Rabotnegi.helpers do
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
  # Helpers
  # 
  
  def absolute_url(*args)
    uri url(*args)
  end
    
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
