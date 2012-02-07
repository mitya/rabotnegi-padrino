require "test_helper"

describe Gore::EventLog do
  setup do
    Gore::EventLog::Item.delete_all
  end
  
  test "write string" do
    Gore::EventLog.write("Source1", "event1", :warn, "message1")
    assert Gore::EventLog::Item.where(source: "Source1", event: "event1", data: "message1", severity: "warn").exists?
  end
  
  test "write array" do
    Gore::EventLog.write("Source", "test", :warn, [:an, "array"])
    assert Gore::EventLog::Item.where(source: "Source", event: "test", data: [:an, "array"], severity: "warn").exists?
    assert Gore::EventLog::Item.where(source: "Source", event: "test", data: ["an", "array"], severity: "warn").exists?    
  end
  
  test "write hash" do
    Gore::EventLog.write("Source", "test", :warn, a: "hash", number: 1, symbol: :hello)
    assert Gore::EventLog::Item.where(source: "Source", event: "test", data: {a: "hash", number: 1, symbol: :hello}, severity: "warn").exists?
    assert Gore::EventLog::Item.where(source: "Source", event: "test", data: {"a" => "hash", "number" => 1, "symbol" => "hello"}, severity: "warn").exists?    
  end
  
  test "shorthand write methods" do
    assert_respond_to Gore::EventLog, :debug
    assert_respond_to Gore::EventLog, :info
    assert_respond_to Gore::EventLog, :warn
    assert_respond_to Gore::EventLog, :error

    Gore::EventLog.error("Source2", "event2", "message2")
    assert Gore::EventLog::Item.where(source: "Source2", event: "event2", data: "message2", severity: "error").exists?    
  end
  
  test "write with extra data" do
    Gore::EventLog.write("S", "e", :warn, {d1: 11, d2: 22}, {e1: 11, e2: 22})
    assert Gore::EventLog::Item.where(source: "S", event: "e", data: {d1: 11, d2: 22}, extra: {e1: 11, e2: 22}, severity: "warn").exists?
  end

  test "nil data and nil extra are not stored" do
    item = Gore::EventLog.write("Src", "evnt", :info)
    item.reload

    assert_equal nil, item.data
    assert_equal nil, item.extra    
    refute item.attributes.include?("data")
    refute item.attributes.include?("extra")
  end

  test ":info severity is not stored" do
    item = Gore::EventLog.write("Src", "evnt", :info)
    item.reload

    assert_equal :info, item.severity
    refute item.attributes.include?("severity")
  end
  
  test "events with low severity are not logged" do
    begin
      old_log_level = Log.level
      Log.level = 2 # warn
      
      Gore::EventLog.write("Src", "debug-message", :debug)
      Gore::EventLog.write("Src", "info-message", :info)
      Gore::EventLog.write("Src", "warn-message", :warn)
      Gore::EventLog.write("Src", "error-message", :error)      
      
      assert Gore::EventLog::Item.where(source: "Src", event: "warn-message").exists?
      assert Gore::EventLog::Item.where(source: "Src", event: "error-message").exists?
      refute Gore::EventLog::Item.where(source: "Src", event: "debug-message").exists?
      refute Gore::EventLog::Item.where(source: "Src", event: "info-message").exists?
    ensure
      Log.level = old_log_level.to_i
    end
  end
end

describe Gore::EventLog::Item do
  test "time" do
    item = Gore::EventLog::Item.create!(source: "Src", event: "evnt")
    assert_equal item.time, item.created_at
  end
  
  test "updated_at is not stored" do
    item = Gore::EventLog::Item.create!(source: "Src", event: "evnt")
    item.reload

    refute_nil item.created_at
    assert_nil item.updated_at
    refute item.attributes.include?("updated_at")
  end
  
end

describe Gore::EventLog::Accessor do
  setup do
    Gore::EventLog::Item.delete_all
  end
  
  test "log attributes" do
    assert_respond_to Vacancy, :log
    assert_respond_to Vacancy.new, :log

    assert_instance_of Gore::EventLog::Writer, Vacancy.log
    assert_instance_of Gore::EventLog::Writer, Vacancy.new.log

    assert_equal "vacancy", Vacancy.log.source
    assert_equal "vacancy", Vacancy.new.log.source
    assert_equal "user", User.log.source
    assert_equal "user", User.new.log.source
    assert_equal "rabotaru_job", Rabotaru::Job.log.source
  end
  
  test "log attributes methods" do
    Vacancy.log.write("some_vacancy_event", :warn, "class message")
    assert Gore::EventLog::Item.where(source: "vacancy", event: "some_vacancy_event", data: "class message", severity: "warn").exists?

    Vacancy.new.log.warn("some_vacancy_event", "instance message")
    assert Gore::EventLog::Item.where(source: "vacancy", event: "some_vacancy_event", data: "instance message", severity: "warn").exists?
  end  
end

describe Gore::EventLog::Writer do
  setup do
    Gore::EventLog::Item.delete_all
  end
  
  test "for_class" do
    assert_equal "user", Gore::EventLog::Writer.for_class(User).source
    assert_equal "rabotaru_job", Gore::EventLog::Writer.for_class(Rabotaru::Job).source
  end
  
  test "write" do
    log = Gore::EventLog::Writer.new("TestSource")

    log.write("event0", :warn, "details0")
    assert Gore::EventLog::Item.where(source: "TestSource", event: "event0", data: "details0").exists?

    log.warn("event1", "details1")
    assert Gore::EventLog::Item.where(source: "TestSource", event: "event1", data: "details1", severity: "warn").exists?
  end
end
