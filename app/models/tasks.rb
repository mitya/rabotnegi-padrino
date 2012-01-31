module Tasks
  extend self
  include EventLog::Accessor
  
  def kill_spam
    bad_emails = %w(gmail.com anyerp.com).join('|')
    bad_ips = %w(85.25.95.90 217.172.180.18)
    
    filter = [ { employer_name: Regexp.new( "@(#{bad_emails})$" ) }, { poster_ip: bad_ips } ]
    vacancies = Vacancy.any_of(filter)
    vacancies.delete_all
          
    # Counter.inc "antispam.runs"
    # Counter.inc "antispam.removed_vacancies", vacancies.count
    
    log.info __method__, removed: vacancies.count    
  end
  
end
