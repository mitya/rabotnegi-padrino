class Vacancy < ApplicationModel
  field :title
  field :description
  field :external_id, type: Integer
  field :industry
  field :city
  field :salary_min, type: Integer
  field :salary_max, type: Integer
  field :employer_id, type: Integer
  field :employer_name
  field :poster_ip, type: String
  field :loaded_at, type: Time
  field :cleaned_at, type: Time
  
  index :city
  index :industry
  index [[:city, 1], [:industry, 1]]
  index [[:city, 1], [:title, 1]]

  validates_presence_of :title, :industry, :city

  belongs_to :employer
  
  scope :old, ->(date = 1.month.ago) { where(:updated_at.lt => date) }

  before_save do
    self.employer_id = employer.id if employer
    self.employer_name = employer.name if employer
  end

  def ==(other)
    Vacancy === other && external_id? ? self.external_id == other.external_id : super
  end

  def to_s
    title
  end
  
  def to_param
    [id, slug].reject(&:blank?).join('-')
  end
  
  def slug
    RussianInflector.parameterize(title).truncate(60, separator: '-', omission: '')    
  end

  def city_name
    City.get(city).name
  end

  def industry_name
    Industry.get(industry).name
  end
  
  def salary
    Salary.new(salary_min, salary_max)
  end
  
  def salary=(salary)
    self.salary_min = self.salary_max = nil
    self.salary_min = salary.min if salary
    self.salary_max = salary.max if salary
  end
  
  def salary_text
    salary.try(:text)
  end
  
  def salary_text=(value)
    self.salary = Salary.parse(value)
  end
  
  def self.search(params)
    params = params.symbolize_keys
    params.assert_valid_keys(:city, :industry, :q)
    query = Regexp.new(params[:q] || "", true)

    scope = self
    scope = scope.where(city: params[:city]) if params[:city].present?
    scope = scope.where(industry: params[:industry]) if params[:industry].present?
    scope = scope.any_of({title: query}, {employer_name: query}, {description: query}) if params[:q].present?
    scope
  end

  instance_eval { alias query search }
  
  def self.get(id)
    id ||= ""
    id = id.gsub(/\-.*/, '') if String === id
    where(_id: id).first
  end
  
  def self.cleanup
    old.destroy
  end
end
