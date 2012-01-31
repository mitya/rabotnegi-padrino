require 'test_helper'

unit_test EventLog do
  setup do
    EventLog::Item.delete_all
  end
  
  test "write string" do
    EventLog.write("Source1", "event1", :warn, "message1")
    assert EventLog::Item.where(source: "Source1", event: "event1", data: "message1", severity: "warn").exists?
  end
  
  test "write array" do
    EventLog.write("Source", "test", :warn, [:an, "array"])
    assert EventLog::Item.where(source: "Source", event: "test", data: [:an, "array"], severity: "warn").exists?
    assert EventLog::Item.where(source: "Source", event: "test", data: ["an", "array"], severity: "warn").exists?    
  end
  
  test "write hash" do
    EventLog.write("Source", "test", :warn, a: "hash", number: 1, symbol: :hello)
    assert EventLog::Item.where(source: "Source", event: "test", data: {a: "hash", number: 1, symbol: :hello}, severity: "warn").exists?
    assert EventLog::Item.where(source: "Source", event: "test", data: {"a" => "hash", "number" => 1, "symbol" => "hello"}, severity: "warn").exists?    
  end
  
  test "shorthand write methods" do
    assert_respond_to EventLog, :debug
    assert_respond_to EventLog, :info
    assert_respond_to EventLog, :warn
    assert_respond_to EventLog, :error

    EventLog.error("Source2", "event2", "message2")
    assert EventLog::Item.where(source: "Source2", event: "event2", data: "message2", severity: "error").exists?    
  end
  
  test "write with extra data" do
    EventLog.write("S", "e", :warn, {d1: 11, d2: 22}, {e1: 11, e2: 22})
    assert EventLog::Item.where(source: "S", event: "e", data: {d1: 11, d2: 22}, extra: {e1: 11, e2: 22}, severity: "warn").exists?
  end

  test "nil data and nil extra are not stored" do
    item = EventLog.write("Src", "evnt", :info)
    item.reload

    assert_equal nil, item.data
    assert_equal nil, item.extra    
    assert !item.attributes.include?("data")
    assert !item.attributes.include?("extra")
  end

  test ":info severity is not stored" do
    item = EventLog.write("Src", "evnt", :info)
    item.reload

    assert_equal :info, item.severity
    assert !item.attributes.include?("severity")
  end
  
  test "events with low severity are not logged" do
    begin
      old_log_level = Log.level
      Log.level = 2 # warn
      
      EventLog.write("Src", "debug-message", :debug)
      EventLog.write("Src", "info-message", :info)
      EventLog.write("Src", "warn-message", :warn)
      EventLog.write("Src", "error-message", :error)      
      
      assert EventLog::Item.where(source: "Src", event: "warn-message").exists?
      assert EventLog::Item.where(source: "Src", event: "error-message").exists?
      assert !EventLog::Item.where(source: "Src", event: "debug-message").exists?
      assert !EventLog::Item.where(source: "Src", event: "info-message").exists?      
    ensure
      Log.level = old_log_level.to_i
    end
  end
end

unit_test EventLog::Item do
  test "time" do
    item = EventLog::Item.create!(source: "Src", event: "evnt")
    assert_equal item.time, item.created_at
  end
  
  test "updated_at is not stored" do
    item = EventLog::Item.create!(source: "Src", event: "evnt")
    item.reload

    assert_not_nil item.created_at
    assert_nil item.updated_at
    assert !item.attributes.include?("updated_at")
  end
  
end

unit_test EventLog::Accessor do
  setup do
    EventLog::Item.delete_all
  end
  
  test "log attributes" do
    assert_respond_to Vacancy, :log
    assert_respond_to Vacancy.new, :log

    assert_instance_of EventLog::Writer, Vacancy.log
    assert_instance_of EventLog::Writer, Vacancy.new.log

    assert_equal "vacancy", Vacancy.log.source
    assert_equal "vacancy", Vacancy.new.log.source
    assert_equal "user", User.log.source
    assert_equal "user", User.new.log.source
    assert_equal "application_controller", ApplicationController.log.source
    assert_equal "rabotaru_job", Rabotaru::Job.log.source
  end
  
  test "log attributes methods" do
    Vacancy.log.write("some_vacancy_event", :warn, "class message")
    assert EventLog::Item.where(source: "vacancy", event: "some_vacancy_event", data: "class message", severity: "warn").exists?

    Vacancy.new.log.warn("some_vacancy_event", "instance message")
    assert EventLog::Item.where(source: "vacancy", event: "some_vacancy_event", data: "instance message", severity: "warn").exists?
  end  
end

unit_test EventLog::Writer do
  setup do
    EventLog::Item.delete_all
  end
  
  test "for_class" do
    assert_equal "user", EventLog::Writer.for_class(User).source
    assert_equal "rabotaru_job", EventLog::Writer.for_class(Rabotaru::Job).source
  end
  
  test "write" do
    log = EventLog::Writer.new("TestSource")

    log.write("event0", :warn, "details0")
    assert EventLog::Item.where(source: "TestSource", event: "event0", data: "details0").exists?

    log.warn("event1", "details1")
    assert EventLog::Item.where(source: "TestSource", event: "event1", data: "details1", severity: "warn").exists?
  end
end
