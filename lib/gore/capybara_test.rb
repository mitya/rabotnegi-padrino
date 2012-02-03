# Capybara.run_server = false
# Capybara.app_host = "http://localhost:3002"
# Capybara.server_port = 3002

# class CapybaraTest < ActionDispatch::IntegrationTest
#   include Capybara::DSL
# 
#   Capybara.default_driver = :webkit
#   Capybara.javascript_driver = :webkit
# 
#   def teardown
#     Capybara.current_driver = Capybara.default_driver
#     super    
#   end
# 
#   def method_missing(method, *args, &block)
#     return super unless method.to_s.starts_with?("assert_")
#     predicate = method.to_s.sub(/^assert_/, '') + '?'
#     return super unless page.respond_to?(predicate)
#     assert page.send(predicate, *args, &block), "Failure: page.#{predicate}#{args.inspect}"
#   end
#   
#   def assert_has_contents(*strings)
#     strings.each { |string| assert_has_content(string) }
#   end
# 
#   def assert_has_no_contents(*strings)
#     strings.each { |string| assert_has_no_content(string) }
#   end
#   
#   def in_content(&block)
#     within '#content', &block
#   end
# 
#   def pick(from, text)
#     select text, from: from
#   end
#   
#   def fill(locator, with)
#     fill_in locator, with: with
#   end
#   
#   def assert_title_like(string)
#     assert_match string, find("title").text
#   end
#   
#   def assert_has_class(target, klass)
#     target = find(target) unless target.is?(Capybara::Node::Element)
#     assert_match /\b#{klass}\b/, target[:class]
#   end
#   
#   def assert_has_no_class(target, klass)
#     target = find(target) unless target.is?(Capybara::Node::Element)
#     assert_no_match(/\b#{klass}\b/, target[:class])
#   end
#   
#   def visit_link(locator)
#     link = find_link(locator)
#     assert_not_nil link, "Link [#{locator}] is not found"
#     visit link['href']
#   end
#   
#   alias sop save_and_open_page
#   
#   def use_rack_test
#     Capybara.current_driver = :rack_test
#   end
# end
