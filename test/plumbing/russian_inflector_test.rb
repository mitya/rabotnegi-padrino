require 'test_helper'

unit_test RussianInflector do
  test "parameterize" do
    assert_equal "ruby-developer", RussianInflector.parameterize("Ruby Developer")    
    assert_equal "ruby-разработчик", RussianInflector.parameterize("Ruby Разработчик")    
    assert_equal "ruby-разработчик", RussianInflector.parameterize("Ruby - Разработчик.")  
    assert_equal "торговый-представитель-20", RussianInflector.parameterize("Торговый представитель № 20")
    assert_equal "менеджер-по-продажам-промышленного-оборудования", RussianInflector.parameterize("Менеджер по продажам промышленного оборудования")
    assert_equal "бухгалтер-по-расчету-заработной-платы", RussianInflector.parameterize("Бухгалтер по расчету заработной платы")
  end
  
  test "truncate" do
    assert_equal "ruby-разработчик", "ruby-разработчик".truncate(30, separator: '-', omission: '')
    assert_equal "менеджер-по-продажам", "менеджер-по-продажам-промышленного-оборудования".truncate(30, separator: '-', omission: '')
    assert_equal "бухгалтер-по-расчету", "бухгалтер-по-расчету-заработной-платы".truncate(30, separator: '-', omission: '')

    assert_equal "ruby-разработчик", "ruby-разработчик".truncate(40, separator: '-', omission: '')
    assert_equal "менеджер-по-продажам-промышленного", "менеджер-по-продажам-промышленного-оборудования".truncate(40, separator: '-', omission: '')
    assert_equal "бухгалтер-по-расчету-заработной-платы", "бухгалтер-по-расчету-заработной-платы".truncate(40, separator: '-', omission: '')
  end
end
