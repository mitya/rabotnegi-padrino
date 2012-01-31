class Salary
	attr_accessor :min, :max, :currency

	def initialize(min = nil, max = nil)
		@currency = :rub
		@min = min
		@max = max
	end
	
	def exact?; @min && @max && @min == @max end
	def exact; @min end
	def exact=(value); @min = value; @max = value end
	def negotiable?; !@min && !@max end
	def negotiable=(value); @min = @max = nil if value end
	def min?; @min && !@max end
	def max?; @max && !@min end
	def range?; @max && @min && @max != @min end

	def ==(other)
	  Salary === other &&
		self.min == other.min && 
		self.max == other.max && 
		self.currency == other.currency
	end 
	
  alias eql? ==

	def to_s
	  case
      when negotiable? then "договорная"
      when exact? then "#{exact.to_i} р."
      when min? then "от #{min.to_i} р."
      when max? then "до #{max.to_i} р."
      when range? then "#{min.to_i}—#{max.to_i} р."
    end
	end

	def text
	  case
      when negotiable? then ""
      when exact? then "#{exact}"
      when min? then "#{min}+"
      when max? then "<#{max}"
      when range? then "#{min}-#{max}"
    end
	end
	
	def text=(value)
	  other = self.class.parse(value)
	  self.min = self.max = nil
	  self.min = other.min
	  self.max = other.max
	end
	
	def convert_currency(new_currency)
		@min = Currency.convert(@min, currency, new_currency) if @min
		@max = Currency.convert(@max, currency, new_currency) if @max
		@currency = new_currency
		self
	end

  def self.make(attributes = {})
    salary = new
    attributes.each { |n,v| salary.send("#{n}=", v) }
    salary
	end
	    
	def self.parse(string)
		string.squish!
		params = case string
  		when /(\d+)\s?[-—]\s?(\d+)/, /от (\d+) до (\d+)/ then { :min => $1.to_i, :max => $2.to_i }
  		when /от (\d+)/, /(\d+)\+/ then { :min => $1.to_i }
  		when /до (\d+)/, /<(\d+)/ then { :max => $1.to_i }
  		when /(\d+)/ then { :exact => $1.to_i }
  		else {}
	  end
		make(params)
	end
end
