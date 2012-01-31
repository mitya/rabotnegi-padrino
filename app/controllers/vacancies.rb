Rabotnegi.controller :vacancies do
  # caches_page :show, :if => -> c { c.request.xhr? }

  get :base, map: "/vacancies" do
    params[:city] = current_user!.city
    params[:industry] = current_user!.industry
    render "vacancies/index"
  end

  get :index, map: "/vacancies/:city(/:industry)", provides: [:html, :json] do
    pass if params[:city].to_i > 0 || params[:city] == "new"
    halt 404 if params[:city] && !City.get(params[:city]) || params[:industry] && !Industry.get(params[:industry])
    halt 404 if content_type == :json && params[:city].blank?
    
    @vacancies = Vacancy.
      search(params.slice(:city, :industry, :q)).
      without(:description).
      order_by(decode_order_to_mongo(params[:sort].presence || "title")).
      paginate(params[:page], 50)
    current_user!.update_if_stored!(city: params[:city], industry: params[:industry])
    
    case content_type
      when :html then render "vacancies/index"
      when :json then render items: @vacancies.map { |v| v.attributes.slice(*%w(title city industry external_id salary_min salary_max employer_name)) }
    end
  end

  get :show, map: "/vacancies/:id", xhr: true do
    @vacancy = Vacancy.get(params[:id])
    partial "vacancies/details"
  end
  
  get :show, map: "/vacancies/:id" do
    @vacancy = Vacancy.get(params[:id])

    halt params[:id] =~ /^\d{6}$/ ? 410 : 404, render("shared/404") unless @vacancy
    redirect url(:vacancies, :show, id: @vacancy) if CGI.unescape(params[:id]) != @vacancy.to_param
    
    render "vacancies/show"
  end

  get :new do
    @vacancy = Vacancy.new
    render "vacancies/form"
  end

  post :create do
    @vacancy = Vacancy.new(params[:vacancy])
    @vacancy.poster_ip = request.remote_ip

    validate_captcha! model: @vacancy, template: :form

    if @vacancy.save
      reset_captcha
      redirect_to vacancy_path(@vacancy), notice: 'Вакансия опубликована'
    else
      render "vacancies/form", status: 422
    end
  end
end
