require 'test_helper'

unit_test Rabotaru::Job do
  test "run w/o problems" do
    Rabotaru::Loader.any_instance.stubs(:load)
    Rabotaru::Processor.any_instance.stubs(:process)

    job = Rabotaru::Job.create!(cities: %W(spb msk), industries: %w(it retail), period: 0.001)
    job.run
    job.reload

    assert_equal :cleaned, job.state
    assert_equal %w(spb msk), job.cities
    assert_equal %w(it retail), job.industries
    assert_equal 4, job.loadings.count
    assert_equal [:done] * 4, job.loadings.pluck(:state)
  end
  
  teardown do
    Rabotaru::Loader.any_instance.unstub(:load)
    Rabotaru::Processor.any_instance.unstub(:process)
  end
  
  test "loadings_to_retry" do
    job = Rabotaru::Job.create!
    job.loadings.create! city: "spb", industry: "it", state: "done"
    job.loadings.create! city: "spb", industry: "retail", state: "done"
    job.loadings.create! city: "msk", industry: "telecom", state: "done"
    job.loadings.create! city: "msk", industry: "building", state: "failed"
    job.loadings.create! city: "msk", industry: "office", state: "started"
      
    loadings_to_retry = job.send(:loadings_to_retry)
    assert loadings_to_retry.detect_eq(city: :msk, industry: :building, state: :pending)
    assert loadings_to_retry.detect_eq(city: :msk, industry: :office, state: :pending)
    assert !loadings_to_retry.detect_eq(city: :spb, industry: :it)
    assert !loadings_to_retry.detect_eq(city: :spb, industry: :retail)
    assert !loadings_to_retry.detect_eq(city: :msk, industry: :telecom)
    assert_equal City.all.count * Industry.all.count - 3, loadings_to_retry.count
  end
  
  test "loadings to retry for a job with a limited input" do
    job = Rabotaru::Job.create!(cities: [:spb, :msk], industries: [:it, :retail])
    job.loadings.create! city: "spb", industry: "it", state: "done"
    job.loadings.create! city: "spb", industry: "retail", state: "done"
    job.loadings.create! city: "msk", industry: "retail", state: "failed"
    job.reload
    
    assert_equal 2, job.send(:loadings_to_retry).count
  end
end
