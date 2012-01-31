# clones = [].to_set
# Vacancy.all.each_with_index do |v1, i|
#   next if v1.external_id.blank?
#   next if clones.include?(v1)
# 
#   dups = Vacancy.where(external_id: v1.external_id, title: v1.title, employer_name: v1.employer_name, city: v1.city, industry: v1.industry, description: v1.description).excludes(id: v1.id).to_a
#   next if dups.empty?
# 
#   dups.unshift(v1)
#   dup_views = dups.map { |v| [v.id, v.created_at.to_s(:num), v.updated_at.to_s(:num)].join('-') }.join(' ')
#   puts "#{v1.external_id}-#{dups.size}: #{dup_views} -- #{v1.title}"
#   
#   clones.merge(dups)
# end

# clones.each do |v|
#   raise "Vacancy #{v.id}/#{v.external_id} is not a clone" unless Vacancy.where(external_id: v.external_id).excludes(id: v.id).present?
# end
# 
# puts "Removing #{clones.size} clones"
# Vacancy.delete_all(conditions: {_id: clones})


uniqs = Vacancy.all.to_a.uniq_by { |v| v.external_id }
puts "Removing #{Vacancy.count - uniqs.count} clones"
Vacancy.not_in(_id: uniqs.map(&:id)).delete_all
