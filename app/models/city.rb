class City < Struct.new(:code, :external_id, :name)
  alias key code

  def to_s
    name
  end

  def inspect
    "City(#{code}/#{external_id} #{name})"
  end

  def key_str
    @key_str ||= key.to_s
  end

  def log_key
    key
  end

  cattr_reader :all
  @@all = [
  	City.new(:msk, 1, "Москва"),
  	City.new(:spb, 2, "Санкт-Петербург"),
  	City.new(:ekb, 3, "Екатеринбург"),
  	City.new(:nn,  4, "Нижний Новгород"),
  	City.new(:nsk, 9, "Новосибирск")  
  ]

  class << self
    def [](code)
      if Array === code
        code = code.map(&:to_sym)
        all.select { |x| x.code.in?(code) }
      else
        all.detect { |x| x.code == code.to_sym }
      end
    end
    alias_method :get, :[]
  
    def each(&block)
      @@all.each(&block)
    end
  
    def find_by_external_id(external_id)
      external_id = external_id.to_i
      city = @@all.find { |city| city.external_id == external_id } || raise(ArgumentError, "Город ##{external_id} не найден")
      city.code
    end    

    def key_matches?(key)
      key = key.to_s
      key.blank? || all.any? { |obj| obj.key_str == key }
    end

    def q
      query = Object.new
      class << query
        def method_missing(selector, *args)
          City[selector.to_sym]
        end
      end
      query
    end
  end  
end

