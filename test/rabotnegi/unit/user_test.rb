require 'test_helper'

unit_test User do
  test "#favorite_vacancies" do
    user = User.create!
    v1 = make Vacancy
    v2 = make Vacancy
    
    user.favorite_vacancies << v1.id
    user.save!    
    user.reload.favorite_vacancies.must_equal [v1.id]

    user.favorite_vacancies << BSON::ObjectId(v2.id.to_s)
    user.save!
    user.reload.favorite_vacancies.must_equal [v1.id, v2.id]
  end
end
