# Convert json data to vacancy models
class Rabotaru::Converter
  include Gore::EventLog::Accessor

  def convert(hash)
    vacancy = Vacancy.new
    vacancy.title = hash['position']
    vacancy.description = hash['responsibility']['value']
    vacancy.external_id = extract_id(hash['link'])
    vacancy.employer_name = hash['employer'] && hash['employer']['value']
    vacancy.city = City.find_by_external_id(hash['city']['id']).to_s
    vacancy.industry = Industry.find_by_external_ids(
      hash['rubric_0'] && hash['rubric_0']['id'], 
      hash['rubric_1'] && hash['rubric_1']['id'], 
      hash['rubric_2'] && hash['rubric_2']['id']
    ).to_s
    vacancy.salary = convert_salary(hash['salary'])
    vacancy.created_at = Time.parse(hash['publishDate'])
    vacancy
  end

  private

  # http://www.rabota.ru/vacancy1234567.html' => 1234567
  def extract_id(link)
    %r{http://www.rabota.ru/vacancy(\d+).html} =~ link
    $1.to_i
  end

  # {"min": "27000", "max": "35000", "currency": {"value": "руб", "id": "2"}} => Salary(min: 27000, max: 35000, currency: :rub)
  # {"min": "10000, "max": "10000", "currency": {"value": "руб", "id": "2"}}
  # {"min": "27000", "currency": {"value": "руб", "id": "2"}}
  # {"agreed":"yes"}
  def convert_salary(hash)
    salary = Salary.new
    if hash['agreed'] == 'yes'
      salary.negotiable = true
    else
      salary.negotiable = false
      case 
        when hash['min'] == hash['max']
          salary.exact = hash['min'].to_i
        when hash['max'].blank?
          salary.min = hash['min'].to_i
        when hash['min'].blank?
          salary.max = hash['max'].to_i
        else
          salary.min = hash['min'].to_i
          salary.max = hash['max'].to_i
      end
      salary.currency = convert_currency(hash['currency']['value'])
      salary.convert_currency(:rub)
    end
    salary
  end

  # 'rub' => :rub
  def convert_currency(currency_name)    
    case currency_name.downcase
      when 'руб', 'rub' then :rub
      when 'usd' then :usd
      when 'eur' then :eur
      else
        log.warn 'convert_currency.unknown', currency: currency_name
        :rub
    end
  end
end
