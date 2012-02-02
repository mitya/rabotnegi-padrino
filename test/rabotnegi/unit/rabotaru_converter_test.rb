require 'test_helper'

unit_test Rabotaru::Converter do
  DATA = ActiveSupport::JSON.decode('{
      "publishDate": "Fri, 19 Sep 2008 20:07:18 +0400",
      "expireDate": "Fri, 26 Sep 2008 20:07:18 +0400",
      "position": "Менеджер",
      "link": "http://www.rabota.ru/vacancy27047845.html",
      "description": "blah-blah-blah-blah-blah", 
      "rubric_0": {"id": "19", "value": "IT, компьютеры, работа в интернете"}, 
      "rubric_1": {"id": "14", "value": "Секретариат, делопроизводство, АХО"}, 
      "rubric_2": {"id": "12", "value": "Кадровые службы, HR"}, 
      "city": {"id": "2", "value": "Санкт-Петербург"}, 
      "schedule": {"id": "1", "value": "полный рабочий день"}, 
      "education": {"id": "3", "value": "неполное высшее"}, 
      "experience": {"id": "2", "value": "до 2 лет"}, 
      "employer": {"id": "15440", "value": "Apple", "link": "http://www.rabota.ru/agency15440.html"}, 
      "salary": {"min": "20000", "max": "30000", "currency": {"value": "руб", "id": "2"}}, 
      "responsibility": {"value": "blah-blah-blah"}
    }')  
  
  setup do
    @expected_vacancy = Vacancy.new(
      title: 'Менеджер',
      city: 'spb',
      industry: 'it',
      external_id: 27047845,
      employer_name: 'Apple',
      description: 'blah-blah-blah',
      created_at: Time.parse('Fri, 19 Sep 2008 20:07:18 +0400'),
      salary: Salary.make(min: 20000.0, max: 30000.0, currency: :rub)
    )

    @converter = Gore::PureDelegator.new(Rabotaru::Converter.new)
  end

  test "convert vacancy" do
    result = @converter.convert(DATA)
    assert_equal @expected_vacancy.attributes.except('_id'), result.attributes.except('_id')
  end

  test "extract ID from URL" do
    assert_equal 1234567, @converter.extract_id('http://www.rabota.ru/vacancy1234567.html')
  end

  test "convert salaru" do
    assert_equal Salary.make(:negotiable => true), @converter.convert_salary('agreed' => 'yes')
    assert_equal Salary.make(:max => 25000, :currency => :rub), @converter.convert_salary('max' => '25000', 'currency' => {'value' => 'руб'})
    assert_equal Salary.make(:exact => 25000, :currency => :rub), @converter.convert_salary('min' => '25000', 'max' => '25000', 'currency' => {'value' => 'руб'})
    assert_equal Salary.make(:min => 17000, :max => 34000, :currency => :rub), @converter.convert_salary('min' => '17000', 'max' => '34000', 'currency' => {'value' => 'руб'})
  end

  test "convert currency" do
    assert_equal :rub, @converter.convert_currency('руб')
    assert_equal :usd, @converter.convert_currency('usd')
    assert_equal :eur, @converter.convert_currency('eur')  
    assert_equal :rub, @converter.convert_currency('gbp')
  end
end
