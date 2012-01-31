# coding: utf-8

require 'test_helper'

class VacanciesControllerTest < ActionController::TestCase
  test 'get' do
    @vacancy = make Vacancy, city: "spb", industry: "it", title: "Программист"
        
    xhr :get, :show, id: @vacancy.to_param
    
    assert_response :ok
    assert_equal @vacancy, assigns(:vacancy)
    assert_template "details"
  end
  
  test "get a non existent record" do
    get :show, id: "4e415504e999fb2522000003"
    assert_response 404
  end

  test "get a record from the old site" do
    get :show, id: "123456"
    assert_response 410
  end
  
  test "get record with wrong slug" do
    @vacancy = make Vacancy, title: "Программист"
    
    get :show, id: "#{@vacancy.id}-developer"
    assert_redirected_to "/vacancies/#{@vacancy.to_param}"
  end
  
  test 'index with filter' do
    v1 = make Vacancy, city: "spb", industry: "it"
    v2 = make Vacancy, city: "spb", industry: "it"
    make Vacancy, city: "msk", industry: "it"
    make Vacancy, city: "spb", industry: "opt"
    
    get :index, city: 'spb', industry: 'it'
    
    assert_response :ok
    assert_same_elements [v1, v2], assigns(:vacancies)
    assert_template "index"
  end
  
  test "index with sorting" do
    v1 = make Vacancy, city: "spb", industry: "it", employer_name: "AAA"
    v2 = make Vacancy, city: "spb", industry: "it", employer_name: "BBB"
  
    get :index, city: 'spb', industry: 'it', sort: "employer_name"
    assert_equal [v1, v2], assigns(:vacancies)
  
    get :index, city: 'spb', industry: 'it', sort: "-employer_name"
    assert_equal [v2, v1], assigns(:vacancies)
  end
  
  test "new" do
    get :new
    assert_response :ok
    assert_template "form"
  end
  
  test "create valid record" do
    post :create, vacancy: { title: "Developer", city: "msk", industry: "it", salary_text: "55000" }

    new_vacancy = Vacancy.last
    assert new_vacancy
    assert_equal "Developer", new_vacancy.title
    assert_equal "msk", new_vacancy.city
    assert_equal "it", new_vacancy.industry
    assert_equal 55_000, new_vacancy.salary.exact
    assert_equal "0.0.0.0", new_vacancy.poster_ip
    
    assert_redirected_to vacancy_path(new_vacancy)
  end

  test "create invalid record" do
    post :create, vacancy: { title: nil }

    assert !Vacancy.last    
    assert_response 422
    assert_template "form"
  end
end
