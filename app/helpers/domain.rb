Rabotnegi.helpers do
  IndustryOptions = [
    ['Популярные', Industry.popular.map { |industry| [industry.name, industry.code.to_s] }],
    ['Остальные', Industry.other.map { |industry| [industry.name, industry.code.to_s] }]
  ]  
  
  SalaryOptions = [
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

  CityOptions = City.all.map { |city| [city.name, city.code.to_s] }
  
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
end
