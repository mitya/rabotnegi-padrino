Rabotnegi.helpers do
  def inspect_field(model, field, options = {})
    value = model.send_chain(field.name) unless field.custom?
    options[:trim] = field.trim

    result = case field.format
      when :city then City.get(value)
      when :industry then Industry.get(value)
      when :pre then element(:pre, trim(value, options[:trim]))
      when String then send(field.format, value)
      when Proc then trim(field.format.(model), options[:trim])
      else inspect_value(value, options)
    end
    
    result = link_to(result, url(:admin_items, :show, collection: field.collection.key, id: model)) if field.format == :link || field.link
    
    result
  end  

  def city_options
    settings.ui_cache.city_options ||= City.all.map { |city| [city.name, city.code.to_s] }
  end

  def industry_options
    settings.ui_cache.industry_options ||= [
      ['Популярные', Industry.popular.map { |industry| [industry.name, industry.code.to_s] }],
      ['Остальные', Industry.other.map { |industry| [industry.name, industry.code.to_s] }]
    ]
  end

  def salary_options
    settings.ui_cache.salary_options ||= [
    	['до 10 000', -10000],
    	['до 20 000', -20000],
    	['до 30 000', -30000],
    	['до 40 000', -40000],
    	['до 50 000', -50000],
    	['от 10 000',  10000],
    	['от 20 000',  20000],
    	['от 30 000',  30000],
    	['от 40 000',  40000],
    	['от 50 000',  50000]
    ]
  end

  def vacancies_page_title
    if @vacancies
      city = City.get(params[:city])
      industry = Industry.get(params[:industry]) if params[:industry].present?
      query = params[:q]
      page = params[:page]
  
      content = "Вакансии — #{city.name}"
      content << " — #{industry.name}" if industry
      content << " — #{query}" if query
      content << ", стр. №#{page}" if page
      content
    else
      "Поиск вакансий"
    end
  end
  
  def back_to_all_vacancies_url_for(vacancy)
    request.referer =~ /vacancies/ ? request.referer : url(:vacancies, :index, city: vacancy.city, industry: vacancy.industry)
  end  
    
  def resumes_page_title
    if @resumes
      city = City[params[:city]] if params[:city].present?
      industry = Industry[params[:industry]] if params[:industry].present?
      query = params[:q]
      page = params[:page]
    
      content = "Резюме — #{city.name}"
      content << " — #{industry.name}" if industry
      content << " — #{query}" if query
      content << ", стр. №#{page}" if page
      content
    else
      "Поиск резюме"
    end
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
