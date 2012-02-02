class Resume < Gore::ApplicationModel
  field :id, type: Integer
  field :fname
  field :lname
  field :password
  field :city
  field :job_title
  field :industry
  field :min_salary, type: Integer
  field :view_count, type: Integer, default: 0
  field :job_reqs
  field :about_me
  field :contact_info

  validates_presence_of :fname, :lname, :city, :job_title, :industry, :contact_info
  validates_numericality_of :min_salary

  def name
    "#{fname} #{lname}".squish
  end
    
  def to_s
    "#{name} — #{job_title} (от #{min_salary} р.)"
  end
    
  def self.search(params)
    params = params.symbolize_keys
    params.assert_valid_keys(:city, :industry, :salary, :keywords)
    query = Regexp.new(params[:keywords] || "")    

    scope = self
    scope = scope.where(city: params[:city]) if params[:city].present?
    scope = scope.where(industry: params[:industry]) if params[:industry].present?
    scope = scope.where(job_title: query) if params[:keywords].present?
    
    if params[:salary].present?
      direction, value = params[:salary].match(/(-?)(\d+)/).captures
      op = direction == '-' ? :lte : :gte
      scope = scope.where(:min_salary.send(op) => value)
    end
    
    scope
  end
  
  instance_eval { alias query search }

  def self.authenticate(name, password)
    name =~ /(\w+)\s+(\w+)/ || raise(ArgumentError, "Имя имеет неправильный формат")
    first, last = $1, $2
    resume = where(lname: last, fname: first).first || raise(ArgumentError, "Резюме «#{name}» не найдено")
    resume.password == password || raise(ArgumentError, "Неправильный пароль")
    resume
  end
end
