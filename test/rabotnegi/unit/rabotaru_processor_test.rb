require 'test_helper'

unit_test Rabotaru::Processor do
  setup do    
    @processor = Rabotaru::Processor.new("demo")  
    Dir.mkdir(@processor.work_dir) unless File.exists?(@processor.work_dir)
  end
  
  test "load" do
    FileUtils.cp Dir.glob(Mu.root.join "test/fixtures/rabotaru/*"), @processor.work_dir
    @processor.read
    assert_equal 60, @processor.vacancies.count
    assert_instance_of Vacancy, @processor.vacancies.first
  end
  
  test "remove_dups" do
    @processor.vacancies = [
      Vacancy.new(external_id: 101),
      Vacancy.new(external_id: 102),
      Vacancy.new(external_id: 103),
      Vacancy.new(external_id: 101),
      Vacancy.new(external_id: 102),
      Vacancy.new(external_id: 104)
    ]

    @processor.remove_duplicates
    
    assert_equal 4, @processor.vacancies.count
    assert_equal [101, 102, 103, 104], @processor.vacancies.pluck(:external_id).sort
  end
  
  test "filter" do
    Vacancy.create!(title: "V-1", city: "spb", industry: "it", external_id: 101, created_at: "2008-09-01", description: "no", loaded_at: "2008-09-01")
    Vacancy.create!(title: "V-2", city: "spb", industry: "it", external_id: 102, created_at: "2008-09-01", description: "no", loaded_at: "2008-09-01")
        
    @processor.vacancies = [
      Vacancy.new(title: 'V-1', city: 'spb', created_at: "2008-09-02", external_id: 101, industry: 'it', description: 'updated'),
      Vacancy.new(title: 'V-2', city: 'spb', created_at: "2008-09-01", external_id: 102, industry: 'it', description: 'no'),
      Vacancy.new(title: 'V-3', city: 'spb', created_at: "2008-09-01", external_id: 103, industry: 'it', description: 'no')
    ]

    @processor.filter
    
    assert @processor.vacancies.any? { |v| v.title == "V-3" }
    assert @processor.vacancies.any? { |v| v.title == "V-1" && v.description == 'updated' }
    assert !@processor.vacancies.any? { |v| v.title == "V-2" }
    
    assert_in_delta Time.now, @processor.vacancies.detect_eq(title: 'V-3').loaded_at, 3.seconds
    assert_equal Time.parse("2008-09-01"), @processor.vacancies.detect_eq(title: 'V-1').loaded_at
  end
  
  test "save" do
    @processor.vacancies = [
      Vacancy.new(title: 'V-5', city: 'spb', external_id: 101, industry: 'it'),
      Vacancy.new(title: 'V-6', city: 'spb', external_id: 102, industry: 'it')
    ]

    @processor.save
    
    assert Vacancy.where(title: 'V-5').exists?
    assert Vacancy.where(title: 'V-6').exists?
  end
end
