N = 100

# data = Vacancy.first.attributes
data = Vacancy.limit(50).map { |v| v.attributes.slice(:title, :city, :industry, :external_id, :salary_min, :salary_max, :employer_name) }

# puts data.as_json
# puts JSON.generate(data.as_json)
puts JSON.generate(data)  

Benchmark.bm(40) do |b|
  b.report("as_json") do
    N.times { data.as_json }
  end

  b.report("to_json (ActiveSupport::JSON.encode)") do
    N.times { data.to_json }
  end

  b.report("JSON.generate(x.as_json)") do
    N.times { JSON.generate(data.as_json) }
  end

  b.report("JSON.generate") do
    N.times { JSON.generate(data) }
  end
end
