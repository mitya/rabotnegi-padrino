module VacancyCleaner
  extend self
  include EventLog::Accessor

  UNESCAPES = {"&quot;" => '"', "&laquo;" => '«', "&raquo;" => '»', "&ndash;" => '–', "&mdash;" => '—', "&#039;" => "'"}
  SANITIZER_OPTIONS = {tags: %w(div strong em b i ul ol li p h3 h4 br hr h5), attributes: %w(id class style)}

  def clean_all(loaded_after = nil)
    collection = loaded_after ? Vacancy.where(:loaded_at.gte => loaded_after) : Vacancy.all
    collection = collection.where(cleaned_at: nil)

    log.info __method__, count: collection.count, threshold: loaded_after

    collection.each { |vacancy| VacancyCleaner.clean(vacancy) }
  end

  def clean(vacancy)
    original_data = {title: vacancy.title, employer_name: vacancy.employer_name, description: vacancy.description}
    store_original_data(vacancy, original_data)
    
    vacancy.title = clean_title(vacancy.title)
    vacancy.employer_name = clean_employer_name(vacancy.employer_name)
    vacancy.description = clean_description(vacancy.description)
    vacancy.cleaned_at = Time.now
    
    vacancy.save!

  rescue => e
    Err.register("VacancyCleaner.clean", e, params: {vacancy_id: vacancy.id})
  end

  def clean_title(title)
    result = (title || "").dup.mb_chars
    result.gsub!(/&[#\w]+;/) { |match| UNESCAPES[match] || match }
    result = result.downcase if result.upcase == result
    result[0] = result[0].upcase if result.first.downcase == result.first
    result = HTML::FullSanitizer.new.sanitize(result)
    result.to_s
  end
  
  def clean_employer_name(employer_name)
    result = (employer_name || "").dup.mb_chars
    result.gsub!(/&[#\w]+;/) { |match| UNESCAPES[match] || match }
    result = HTML::FullSanitizer.new.sanitize(result)
    result.to_s
  end

  def clean_description(description)
    desc = (description || "").dup.mb_chars
    
    desc.gsub! /\n/, '<br />' if desc !~ /<\w+/
    
    desc.squish!
    desc.gsub! /&nbsp;/, ' '
    desc.gsub! /&sbquo;/, ','
    desc.gsub! /&quot;/, '"'

    desc.gsub! %r{(\w+>)\s+(</?\w)}, '\1 \2' # tag>    </?tag => tag> </tag
    desc.gsub! %r{(<br />\s*)+}, '<br>' # <br />  <br /> => <br>
    desc.gsub! %r{(<strong>)+}, '<strong>'
    desc.gsub! %r{(</strong>)+}, '</strong>'
    desc.gsub! %r{<strong>(Требования|Условия|Обязанности):?</strong>}, '<h4>\1</h4>'
    desc.gsub! %r{</h4>:}, '</h4>'
    desc.gsub! %r{<strong><br></strong>}, ''
    desc.gsub! %r{<strong>}, ''
    desc.gsub! %r{</strong>}, ''

    desc.gsub! %r{(</(h4|ul)+>)<br>}, '\1'
    desc.gsub! %r{([^<>]*)<br>}, '<p>\1</p>'
    desc.gsub! %r{<br>(<(h4|ul)+)}, '\1'
    desc.gsub! %r{&bull;(.*?)(?=&bull;|<|\Z)}, '<p>• \1</p>'
    desc.gsub! %r{<p>\s*(-|\*|·)\s*}, '<p>• '
    desc.gsub! %r{</ul>\s*<ul>}, ''    
    desc.gsub! %r{<li>\s*-\s*}, '<li>'
    
    desc.gsub! %r{<li>\s*</li>}, ''    
    desc.gsub! %r{<ul>\s*</ul>}, ''
    desc.gsub! %r{<ul><ul>}, '<ul>'
    desc.gsub! %r{</ul></ul>}, '</ul>'
    desc.gsub! %r{<p>[\s-]*</p>}, ''
    desc.squish!
    desc = HTML::WhiteListSanitizer.new.sanitize(desc, SANITIZER_OPTIONS)
    
    desc.to_s
  end    
    
  private
    
  def store_original_data(vacancy, data)
    working_dir = Se.original_vacancies_data_dir.join(vacancy.created_at.strftime("%Y%m"))
    working_dir.mkpath
    File.write(working_dir.join("#{vacancy.id}.json"), JSON.generate(data))
  end
end
