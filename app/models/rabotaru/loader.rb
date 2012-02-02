# Loads the vacancies feed into tmp/rabotaru-DATE/CITY-INDUSTRY.rss
class Rabotaru::Loader
  FeedUrlTemplate = "http://www.rabota.ru/v3_jsonExport.html?wt=f&c=%{city}&r=%{industry}&ot=t&cu=2&p=30&d=desc&cs=t&start=0&pp=50&fv=f&rc=992&new=1&t=1&country=1&c_rus=2&c_ukr=41&c_ec=133&sm=103"
  attr_accessor :working_directory, :city, :industry
  include Gore::EventLog::Accessor

  def initialize(city, industry, job_key = Gore.date_stamp)
    @working_directory = Se.rabotaru_dir.join(job_key)
    @city = City.get(city)
    @industry = Industry.get(industry)
  end

  def load
    working_directory.mkpath
    feed_file = working_directory.join("#{city.key}-#{industry.key}.json")
    return if feed_file.size?

    feed_url = FeedUrlTemplate % {city: city.external_id, industry: industry.external_id}
    feed_json = Http.get(feed_url)
    File.write(feed_file, feed_json)
    log.info 'feed_loaded', [city.key, industry.key, feed_json.size]
  end  
end
