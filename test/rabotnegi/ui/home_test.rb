require 'test_helper'

ui_test "Home" do
  test "home page" do
    visit "/"

    within '#header' do
      assert_has_link "Поиск вакансий"
      assert_has_link "Публикация вакансий"
    end  
  end  
  
  # test "site info" do
  #   visit "/site/info"
  #   save_and_open_page
  # end
end
