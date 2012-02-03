require 'test_helper'

unit_test VacancyCleaner do
  test "clean title" do
    assert_equal "Помошник повара", VacancyCleaner.clean_title("ПОМОШНИК ПОВАРА")
    assert_equal "Помошник повара", VacancyCleaner.clean_title("помошник повара")
    assert_equal "Программист на .NET", VacancyCleaner.clean_title("программист на .NET")
    
    assert_equal %{"Quotes" «Rusquotes» – 'Quote'}, VacancyCleaner.clean_title("&quot;Quotes&quot; &laquo;Rusquotes&raquo; &ndash; &#039;Quote&#039;")
  end

  test "clean employer name" do
    assert_equal %{"Quotes" «Rusquotes» – 'Quote'}, VacancyCleaner.clean_employer_name("&quot;Quotes&quot; &laquo;Rusquotes&raquo; &ndash; &#039;Quote&#039;")
  end
  
  test "clean description" do
    f = ->(str) { VacancyCleaner.clean_description(str) }
    
    assert_equal %{, "}, f.("&nbsp; &sbquo; &quot;")
    assert_equal "<p>aa bb </p><p>cc </p>", f.("  aa  bb  \n  cc  \n  ")
    assert_equal "TEXT", f.("<strong><strong><strong>TEXT</strong></strong></strong>")    
    assert_equal "<h4>Требования</h4>", f.("<strong><strong><strong>Требования</strong></strong></strong>")    
    assert_equal "<p>• hello</p>", f.("<p> - hello</p>")    
    assert_equal "<p>• hello</p>", f.("<p> * hello</p>")    
    assert_equal "<p>• hello</p>", f.("<p>* hello</p>")    
    # assert_equal "<p>• hello</p>", f.("<p> &bull; hello</p>")    
  end
  
  test "clean" do
    vacancy = make Vacancy, title: "РАБОЧИЙ", employer_name: "&quot;Газпром&quot;", description: "<strong>Тест</strong>"
    VacancyCleaner.clean(vacancy)
    
    vacancy.reload
  
    assert_equal "Рабочий", vacancy.title
    assert_equal '"Газпром"', vacancy.employer_name
    assert_equal "Тест", vacancy.description
    
    original_data = JSON.parse Rabotnegi.config.original_vacancies_data_dir.join(Time.now.strftime("%Y%m")).join("#{vacancy.id}.json").read
    
    assert_equal "РАБОЧИЙ", original_data["title"]
    assert_equal '&quot;Газпром&quot;', original_data["employer_name"]
    assert_equal "<strong>Тест</strong>", original_data["description"]
  end
end
