Rabotnegi.controllers do
  get "/" do    
    render "vacancies/index"
  end

  get "/sitemap.xml" do
    render "site/map"
  end

  get "/site/info" do
    render env: Gore.env, db: Vacancy.db.name, counts: { vacancies: Vacancy.count, events: Gore::EventLog::Item.count, users: User.count }
  end

  get "/site/env" do
    Gore.env
  end

  # 
  # Dev
  # 

  get "/tests/noop" do
    ""
  end

  get "/tests/error" do
    raise ArgumentError, "shit happens"
  end


  get '/dev/request' do
    render env.select { |k,v| [String, Numeric, Symbol, TrueClass, FalseClass, NilClass, Array, Hash].any? { |klass| klass === v } }
  end
  
  get "/dev/error" do
    raise "shit happens"
  end

  get "dev/typo" do
    bum_bum_shit
  end
  
  get "/dev" do
    render "dev/dev"
  end
end
