require 'test_helper'

describe "Vacancies controller" do
  test 'GET /vacancies/:id via XHR' do
    @vacancy = make Vacancy, city: "spb", industry: "it", title: "Программист"

    get URI.encode("/vacancies/#{@vacancy.to_param}"), {}, xhr: true
    
    assert last_response.ok?
    assert_includes last_response.body, "entry-details"
    refute_includes last_response.body, "<meta"
  end

  test "GET /vacancies/:non-existing" do
    get "/vacancies/4e415504e999fb2522000003"
    assert_equal 404, last_response.status
  end

  test "GET /vacancies/:old-site-id" do
    get "/vacancies/123456"
    assert_equal 410, last_response.status    
  end
  
  test "GET /vacancies/:id-with-wrong-slug" do
    @vacancy = make Vacancy, title: "Программист"
    
    get "/vacancies/#{@vacancy.id}-developer"
    assert last_response.redirect?
    assert_match URI.encode("/vacancies/#{@vacancy.to_param}"), last_response.location
  end
  
  test 'GET /vacancies/:city/:industry' do
    v1 = make Vacancy, city: "spb", industry: "it"
    v2 = make Vacancy, city: "spb", industry: "it"
    v3 = make Vacancy, city: "msk", industry: "it"
    v4 = make Vacancy, city: "spb", industry: "opt"
    
    get "/vacancies/spb/it"
    
    assert last_response.ok?
    assert_includes last_response.body, v1.title
    assert_includes last_response.body, v2.title
    refute_includes last_response.body, v3.title
    refute_includes last_response.body, v4.title
  end
  
  test "GET /vacancies/:city/:industry with sorting" do
    v1 = make Vacancy, city: "spb", industry: "it", employer_name: "AAA"
    v2 = make Vacancy, city: "spb", industry: "it", employer_name: "BBB"
  
    get "/vacancies/spb/it", sort: "employer_name"
    assert_match /#{v1.title}.*#{v2.title}/, last_response.body

    get "/vacancies/spb/it", sort: "-employer_name"
    assert_match /#{v2.title}.*#{v1.title}/, last_response.body
  end
  
  test "new" do
    skip
    get :new
    assert_response :ok
    assert_template "form"
  end
  
  test "create valid record" do
    skip
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
    skip
    post :create, vacancy: { title: nil }
  
    assert !Vacancy.last    
    assert_response 422
    assert_template "form"
  end
end
