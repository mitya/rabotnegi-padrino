Rabotnegi.controller :vacancies do
  # caches_page :show, :if => -> c { c.request.xhr? }
  get :new do
    @vacancy = Vacancy.new
    render "vacancies/form"
  end

  get :search, "/vacancies" do
    params.merge! city: current_user.city, industry: current_user.industry
    render "vacancies/index"
  end

  get :index_for_json, "/vacancies.json" do
    @vacancies = Vacancy.search(params.slice(:city, :industry, :q)).without(:description).
      order_by(decode_order_to_mongo(params[:sort].presence || "title")).paginate(params[:page], 50)
    render items: @vacancies.map { |v| v.attributes.slice(*%w(title city industry external_id salary_min salary_max employer_name)) }
  end

  get :index, "/vacancies/:city(/:industry)", if_params: {city: City, industry: Industry} do
    @vacancies = Vacancy.search(params.slice(:city, :industry, :q)).without(:description).
      order_by(decode_order_to_mongo(params[:sort].presence || "title")).paginate(params[:page], 50)
    current_user.update_if_stored!(city: params[:city], industry: params[:industry])
    render "vacancies/index"
  end
  
  get :favorite do
    @vacancies = current_user.favorite_vacancy_objects
    render "vacancies/favorite"
  end

  get :show, "/vacancies/:id", xhr: true do
    @vacancy = Vacancy.get(params[:id])
    partial "vacancies/details"
  end
  
  get :show, "/vacancies/:id" do
    @vacancy = Vacancy.get(params[:id])
  
    return params[:id] =~ /^\d{6}$/ ? 410 : 404, render("shared/404") unless @vacancy
    redirect url(:vacancies_show, id: @vacancy) if CGI.unescape(params[:id]) != @vacancy.to_param
    
    render "vacancies/show"
  end

  post :create do
    @vacancy = Vacancy.new(params[:vacancy])
    @vacancy.poster_ip = request.ip

    # validate_captcha! model: @vacancy, template: :form

    if @vacancy.save
      # reset_captcha
      flash[:notice] = 'Вакансия опубликована'
      redirect url(:vacancies_show, id: @vacancy)
    else
      return 422, render("vacancies/form")
    end    
  end

  post :remember, with: :id do
    current_user.favorite_vacancies << BSON::ObjectId(params[:id])
    current_user.save!
    200
  end

  post :forget, with: :id do
    current_user.favorite_vacancies.delete BSON::ObjectId(params[:id])
    current_user.save!
    200
  end
end
