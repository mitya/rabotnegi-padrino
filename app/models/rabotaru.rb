module Rabotaru
  def self.start_job(options = {})
    Job.create!(options).run
  end
end
