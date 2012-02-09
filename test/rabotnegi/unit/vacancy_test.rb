require 'test_helper'

unit_test Vacancy do
  setup do
    @vacancy = Vacancy.new    
  end
  
  test 'default salary' do
    assert @vacancy.salary.negotiable?
  end
  
  test "#salary_text=" do
    vacancy = Vacancy.new(salary: Salary.make(exact: 1000))
    assert_equal Salary.make(exact: 1000), vacancy.salary
    vacancy.salary_text = "от 5000"
    assert_equal Salary.make(min: 5000), vacancy.salary
    assert_equal 5000, vacancy.salary_min
    assert_equal nil, vacancy.salary_max
  end
  
  test "#==" do
    assert Vacancy.new != nil
    assert Vacancy.new != Vacancy.new
    assert Vacancy.new(title: "Boss") != Vacancy.new(title: "Boss")
    assert_equal Vacancy.new(title: "Boss", external_id: 100), Vacancy.new(title: "Developer", external_id: 100)
  end
  
  test "#to_param" do
    v1 = make(Vacancy, title: "Ruby Разработчик")
    assert_equal "#{v1.id}-ruby-разработчик", v1.to_param
    
    v1.title = nil
    assert_equal v1.id.to_s, v1.to_param
  end
  
  test "long slugs" do
    assert_equal "ruby-разработчик", make(Vacancy, title: "Ruby Разработчик").slug
    assert_equal "менеджер-по-продажам-промышленного-оборудования", make(Vacancy, title: "Менеджер по продажам промышленного оборудования").slug
    assert_equal "ааааааа-бббббббббб-вввввввввв-ггггггггггг-дддддддд-еееееееее", make(Vacancy, title: "Ааааааа Бббббббббб вввввввввв ггггггггггг дддддддд еееееееее жжжжжжж").slug
  end

  test "#get" do
    v1 = make Vacancy

    assert_equal v1, Vacancy.get(v1.id)
    assert_equal v1, Vacancy.get(v1.id.to_s)
    assert_equal v1, Vacancy.get("#{v1.id}-xxxx-1111")
    assert_equal v1, Vacancy.get("#{v1.id}-1111-xxxx")

    assert_nil Vacancy.get("4daebd518c2e000000000000")
  end  

  test "#search" do
    v1_msk_retail = make Vacancy, title: "query-1", city: "msk", industry: "retail"
    v1_spb_it = make Vacancy, description: "query-1", city: "spb", industry: "it"
    v2 = make Vacancy, description: "query-2"    
    v3 = make Vacancy, employer_name: "query-3"    
    
    Vacancy.search(q: "query-1").must_eq [v1_msk_retail, v1_spb_it]
    Vacancy.search(q: "query-2").must_eq [v2]
    Vacancy.search(q: "query-3").must_eq [v3]
    
    Vacancy.search(q: "query-1", city: "msk").must_eq [v1_msk_retail]    
    Vacancy.search(q: "query-1", industry: "it").must_eq [v1_spb_it]
  end
end
