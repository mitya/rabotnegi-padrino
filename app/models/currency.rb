class Currency
  @@map = {
  	:usd => "$",
  	:eur => "€",
  	:rub => "руб."
  }

  @@map = {
    usd: "$", 
    eur: "€", 
    rub: "руб."
  }

  @@list = [:rub, :usd, :eur]
  @@rates = { rub: 1.0, usd: 31, eur: 42	}  
  
  class << self
  	def convert(value, source_currency_sym, target_currency_sym)
  		value * rate(source_currency_sym) / rate(target_currency_sym)
  	end
	
  	def rate(currency)
  	  @@rates[currency]
  	end
  end
end
