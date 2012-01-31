class Employer < ApplicationModel
  field :name
  field :login
  field :password
  field :id, type: Integer   

  validates_presence_of :name, :login, :password
  validates_uniqueness_of :login
  validates_confirmation_of :password

  has_many :vacancies

  attr_accessor :password_confirmation
  
  def to_s
    name
  end
  
  def add_vacancy(vacancy)
    vacancy.employer_id = id
    vacancy.employer_name = name    
    vacancies << vacancy    
  end

  def self.authenticate(login, password)
    where(:login => login, :password => password).first || raise(ArgumentError)
  end
end
