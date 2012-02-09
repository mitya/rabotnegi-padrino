module Gore::Testing
  module Globals
    def ui_test(name, &block)
      describe name do
        include Capybara::DSL
        include Gore::Testing::CapybaraHelpers
        
        after { Capybara.current_driver = Capybara.default_driver }

        class_eval(&block)
      end
    end  
  end
  
  module Cases
    def no_test(*args)
    end
    
    def visual_test(name, &block)
      # test(name, &block)
    end
    
    def temp_class(base = Object, &block)
      name = "TempClass#{rand(1000)}"
      Gore::Testing::Cases.const_set(name, Class.new(base, &block))
    end        
  end

  module Helpers
    def make(factory_name, *args, &block)
      factory_name = factory_name.model_name.singular if Class === factory_name
      Factory(factory_name, *args, &block)
    end
    
    def patch(*args)
      Stubber.stub(*args)
    end
    
    def sent_emails
      Mail::TestMailer.deliveries
    end
  end
  
  module RackHelpers
    def gets(*args)
      get(*args)
      assert_equal 200, last_response.status
    end
  end
  
  module Assertions
    def assert_equals(actual, expected, msg = nil)
      assert_equal(expected, actual, msg)
    end

    def assert_matches(value, pattern, msg = nil)
      assert_match(pattern, value, msg)
    end
  
    def assert_size(size, collection)
      assert_equal size, collection.size
    end
    
    def assert_blank(object)
      assert object.blank?
    end
    
    def assert_same_elements(a1, a2)
      assert_equal a1.size, a2.size
      a1.each { |x| assert a2.include?(x), "#{a2.inspect} is expected to include #{x.inspect}" }
    end
    
    def assert_emails(count)
      assert_equal count, sent_emails.count
    end
  end
  
  module CapybaraHelpers
    def assert_has_contents(*strings)
      strings.each { |string| assert_has_content(string) }
    end

    def assert_has_no_contents(*strings)
      strings.each { |string| assert_has_no_content(string) }
    end
  
    def in_content(&block)
      within '#content', &block
    end

    def pick(from, text)
      select text, from: from
    end
  
    def fill(locator, with)
      fill_in locator, with: with
    end
  
    def assert_title_like(string)
      assert_match string, find("title").text
    end
  
    def assert_has_class(target, klass)
      target = find(target) unless target.is?(Capybara::Node::Element)
      assert_match %r{\b#{klass}\b}, target[:class]
    end
  
    def assert_has_no_class(target, klass)
      target = find(target) unless target.is?(Capybara::Node::Element)
      refute_match(/\b#{klass}\b/, target[:class])
    end
  
    def visit_link(locator)
      link = find_link(locator)
      assert link, "Link [#{locator}] is not found"
      visit link['href']
    end
  
    def sop
      save_and_open_page
    end
  
    def use_rack_test
      Capybara.current_driver = :rack_test
    end    
    
    def method_missing(method, *args, &block)
      return super unless method.to_s.starts_with?("assert_")
      predicate = method.to_s.sub(/^assert_/, '') + '?'
      return super unless page.respond_to?(predicate)
      assert page.send(predicate, *args, &block), "Failure: page.#{predicate}#{args.inspect}"
    end     
  end
end

