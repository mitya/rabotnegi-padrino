require 'test_helper'

ui_test "Vacancies" do
  describe "search" do
    test "link to search page" do
      visit "/"
      click_link "Поиск вакансий"
      assert_equal "/vacancies", current_path
    end
  
    test "search page" do
      visit "/vacancies"
      in_content do
        assert_has_select "Город"
        assert_has_select "Отрасль"
        assert_has_field "Ключевые слова"
      end
    end
  
    test "search by city/industry" do
      visit "/vacancies"
    
      pick 'Город', 'Санкт-Петербург'
      pick 'Отрасль', 'Информационные технологии'
      click_button "Найти"
  
      in_content do
        assert_has_contents "Designer", "Ruby Developer", "Apple"
        assert_has_no_contents "Главбух", "Рога и Копыта" # other industry/city
        assert_has_no_contents "Msk Co" # other city      
      end
    end
  
    test "search with query" do
      visit "/vacancies"
        
      pick 'Город', 'Санкт-Петербург'
      pick 'Отрасль', 'Информационные технологии'
      fill 'Ключевые слова', 'Java'
      click_button "Найти"
  
      in_content do
        assert_has_contents "JavaScript Developer"
        assert_has_no_contents "Ruby Developer"
      end
    end
  
    test "search without results" do
      visit "/vacancies"    
    
      pick 'Город', 'Екатеринбург'
      pick 'Отрасль', 'Информационные технологии'
      click_button "Найти"
  
      in_content do
        assert_has_content "Информации о вакансиях в выбранном городе/отрасли сейчас нет"
      end  
    end 
  end
  
  describe "search results" do
    test "view search result" do
      vacancy = Vacancy.where(title: "JavaScript Developer", city: 'spb').first
      vacancy_block = "#v-#{vacancy.id}-details .entry-box"
        
      visit "/vacancies"
  
      pick 'Город', 'Санкт-Петербург'
      fill 'Ключевые слова', 'javascript'
      click_button "Найти"
  
      click_link "JavaScript Developer"
      assert_has_selector vacancy_block, visible: true, text: "Do some JS and frontend stuff"
  
      click_link "JavaScript Developer"
      assert_has_selector vacancy_block, visible: false
      
      within(vacancy_block) { visit_link("Открыть вакансию на отдельной странице") }
    
      assert_has_selector 'h2', text: "JavaScript Developer"
      assert_title_like "JavaScript Developer"
    end   
  end

  describe "posting" do
    test "post" do
      title = "Негr ##{Gore.time_stamp}"
      
      visit "/vacancies/new"
      
      fill "Должность", title
      fill "Работодатель", "СтройНам"
      pick "Город", "Москва"        
      pick "Отрасль", "Строительство и архитектура"        
      fill "Зарплата", "30000"
      fill "Описание", "ла-ла-ла-ла надо нам е-щёёё бабла"
      
      click_button "Опубликовать"
    
      assert_has_content "Вакансия опубликована"
    
      vacancy = Vacancy.asc(:created_at).last
      vacancy.title.must_equal title 
      vacancy.city.must_equal "msk"
      vacancy.industry.must_equal "building"
      vacancy.employer_name.must_equal "СтройНам"
      vacancy.description.must_equal "ла-ла-ла-ла надо нам е-щёёё бабла"
      vacancy.salary.must_equal Salary.make(exact: 30_000)
      
      assert_title_like title
      assert_has_content title
      assert_has_content "ла-ла-ла-ла надо нам е-щёёё бабла"
    end
    
    test "post invalid data" do
      title = "Негr ##{Gore.time_stamp}"
      
      visit "/vacancies/new"
      click_button "Опубликовать"
      
      assert_has_content "Вы что-то неправильно заполнили"
      within(".errors") { assert_has_content "Должность" }
    end   
  end

  describe "favorites" do
    test "favorites" do
      record = Vacancy.where(title: "JavaScript Developer", city: 'spb').first
      row = "#v-#{record.id}"
      
      visit "/vacancies"
      User.last.update_attributes(favorite_vacancies: [])
    
      pick 'Город', 'Санкт-Петербург'
      pick 'Отрасль', 'Информационные технологии'
      click_button "Найти"
      
      assert_equal [], User.last.favorite_vacancies

      assert_has_no_class find(row + " .star"), "star-enabled"
      find(row + " .star").click
      
      skip "seems we can't click spans here"
      assert_has_class find(row + " .star"), "star-enabled"
      
      assert_equal [record.id], User.last.favorite_vacancies
      
      visit "/vacancies/favorite"
      in_content do
        assert_has_selector "tr.entry-header", count: 1
        assert_has_content "JavaScript Developer"
      end
    end    
  end
end
