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
  
    
  def captcha_valid?
    return @captcha_valid unless @captcha_valid.nil?
    @captcha_valid = Gore::Captcha.valid?(params[:captcha_id], params[:captcha_text])
  end

  def captcha_valid!(object = nil)
    if captcha_valid?
      true
    else
      object.errors.add(:captcha, "invalid") if object
      log.warn 'captcha_wrong', ip_adress: request.ip, captcha_text: params[:captcha_text]
      false
    end
  end
  
  def captcha_section
    if captcha_valid?
      hidden_field_tag(:captcha_text, value: params[:captcha_text]) + hidden_field_tag(:captcha_id, value: params[:captcha_id])
    else
      @captcha = Gore::Captcha.create!
      @captcha_url = url(:captcha, id: @captcha)
      div "captcha" do
        image_tag(@captcha_url, width: 100, height: 28) + br + text_field_tag(:captcha_text) + hidden_field_tag(:captcha_id, value: @captcha.id)
      end
    end
  end
end
