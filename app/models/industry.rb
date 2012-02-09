class Industry < Struct.new(:code, :external_id, :name, :group)
  cattr_reader :all, :popular, :other
  alias key code

  def to_s
    name
  end
  
  def self.[](code)
    if Array === code
      code = code.map(&:to_sym)
      all.select { |x| x.code.in?(code) }
    else
      all.detect { |x| x.code == code.to_sym }
    end
  end
  singleton_class.send(:alias_method, :get, :[])
  
  def self.each(&block)
    @@all.each(&block)
  end
  
  def self.find_by_external_id(external_id)
    external_id = external_id.to_i
    industry = @@all.find { |industry| industry.external_id == external_id } || raise(ArgumentError, "Отрасль ##{external_id} не найдена")
    industry.code
  end

  def self.find_by_external_ids(*external_ids)
    external_ids.each do |eid|
      return find_by_external_id(eid) rescue next
    end
  end
  
  def self.key_matches?(key)
    key = key.to_s
    key.blank? || all.any? { |obj| obj.key_str == key }
  end
  
  def key_str
    @key_str ||= key.to_s
  end
  
  def log_key
    key
  end
    
  @@all = [
     Industry.new(:it,                      19, 'Информационные технологии',    :popular),
     Industry.new(:finance,                  2, 'Бухгалтерия и финансы',        :popular),
     Industry.new(:transportation,          83, 'Транспорт',                    :popular),
     Industry.new(:logistics,               78, 'Логистика',                    :popular),
     Industry.new(:service,                 92, 'Обслуживающий персонал',       :popular),
     Industry.new(:wholesale,               75, 'Оптовая торговля',             :popular),
     Industry.new(:manufactoring,           22, 'Производство',                 :popular),
     Industry.new(:restaurant,              85, 'Рестораны и питание',          :popular),
     Industry.new(:retail,                  60, 'Розничная торговля',           :popular),
     Industry.new(:office,                  14, 'Делопроизводство',             :popular),
     Industry.new(:building,                37, 'Строительство и архитектура',  :popular),
     Industry.new(:hr,                      12, 'Кадровые службы',              :other),                      
     Industry.new(:marketing,               49, 'Маркетинг, реклама, PR',       :other),  
     Industry.new(:medicine,                90, 'Медицина, фармация',           :other),  
     Industry.new(:realty,                 107, 'Недвижимость',                 :other),  
     Industry.new(:sales,                 1011, 'Продажа услуг',                :other),  
     Industry.new(:publishing,              55, 'Издательство, полиграфия',     :other),  
     Industry.new(:insurance,              109, 'Страхование',                  :other),  
     Industry.new(:telecom,                 94, 'Телекоммуникации',             :other),  
     Industry.new(:executives,             751, 'Топ-менеджмент',               :other),  
     Industry.new(:hospitality,            111, 'Туризм, гостиничное дело',     :other),  
     Industry.new(:telework,              1006, 'Удаленная работа',             :other),  
     Industry.new(:householding,            46, 'Эксплуатация зданий',          :other),  
     Industry.new(:law,                      9, 'Юриспруденция',                :other)                          
  ].sort_by(&:name)

  @@popular, @@other = @@all.partition { |industry| industry.group == :popular }

  def self.q
    query = Object.new
    class << query
      def method_missing(selector, *args)
        Industry[selector.to_sym]
      end
    end
    query
  end
end
