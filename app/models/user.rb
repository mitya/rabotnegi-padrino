class User < Gore::ApplicationModel
  field :industry
  field :city  
  field :agent
  field :ip
  field :queries, type: Array
  field :favorite_vacancies, type: Array, default: []
  
  def favorite_vacancy_objects
    Vacancy.find(favorite_vacancies)
  end
  
  def to_s
    "User@#{ip}"
  end
end
