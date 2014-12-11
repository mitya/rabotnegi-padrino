require 'test_helper'

describe "Vacancies controller" do
  test 'GET /vacancies/:id via XHR' do
    @vacancy = make Vacancy, city: "spb", industry: "it", title: "Программист"

    gets URI.encode("/vacancies/#{@vacancy.to_param}"), {}, xhr: true
    
    assert_have_no_selector "meta"
    assert_have_selector ".entry-details"
  end

  test "GET /vacancies/:non-existing" do
    get "/vacancies/4e415504e999fb2522000003"
    assert_equal 404, response.status
  end

  test "GET /vacancies/:old-site-id" do
    get "/vacancies/123456"
    assert_equal 410, response.status    
  end
  
  test "GET /vacancies/:id-with-wrong-slug" do
    @vacancy = make Vacancy, title: "Программист"
    
    get "/vacancies/#{@vacancy.id}-developer"
    assert response.redirect?
    assert_match URI.encode("/vacancies/#{@vacancy.to_param}"), response.location
  end
  
  test 'GET /vacancies/:city/:industry' do
    v1 = make Vacancy, city: "spb", industry: "it"
    v2 = make Vacancy, city: "spb", industry: "it"
    v3 = make Vacancy, city: "msk", industry: "it"
    v4 = make Vacancy, city: "spb", industry: "opt"
    
    gets "/vacancies/spb/it"

    response.body.must_include v1.title
    response.body.must_include v2.title
    response.body.wont_include v3.title
    response.body.wont_include v4.title
  end
  
  test "GET /vacancies/:city/:industry with sorting" do
    v1 = make Vacancy, city: "spb", industry: "it", employer_name: "AAA"
    v2 = make Vacancy, city: "spb", industry: "it", employer_name: "BBB"
  
    gets "/vacancies/spb/it", sort: "employer_name"
    response.body.must_match %r{#{v1.title}.*#{v2.title}}

    gets "/vacancies/spb/it", sort: "-employer_name"
    response.body.must_match %r{#{v2.title}.*#{v1.title}}
  end
  
  test "new" do
    gets "/vacancies/new"
    assert_contain "Публикация новой вакансии"
  end
  
  test "create valid record" do
    $all_captchas_are_valid = true
    post "/vacancies/create", vacancy: { title: "Developer", city: "msk", industry: "it", salary_text: "55000" }
  
    new_vacancy = Vacancy.last
    new_vacancy.wont_be_nil
    new_vacancy.title.must_equal "Developer"
    new_vacancy.city.must_equal "msk"
    new_vacancy.industry.must_equal "it"
    new_vacancy.salary.exact.must_equal 55_000
    new_vacancy.poster_ip.must_equal "127.0.0.1"
    
    response.must_be :redirect?
    response.location.must_match app.url(:vacancies, :show, id: new_vacancy)
  end
  
  test "create invalid record" do
    post "/vacancies/create", vacancy: { title: nil }
  
    response.status.must_equal 422
    Vacancy.last.must_be_nil
    assert_contain "Публикация новой вакансии"
  end
  
  after do
    $all_captchas_are_valid = false
  end
end
