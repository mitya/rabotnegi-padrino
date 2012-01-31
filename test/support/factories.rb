Factory.define :vacancy do |f|
  f.sequence :title do |n| "Test Vacancy ##{n}" end
  f.description "lorem lorem lorem"
  f.city "msk"
  f.industry "it"
  f.salary_min 50_000
  f.employer_name "The Test Company"
  f.sequence :external_id do |n| n + 100_000 end
end
