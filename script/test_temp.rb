Rabotaru::Loader.new(city: 'spb', industry: 'it').load

Rack::Mount::Utils.const_set(:UNSAFE_PCHAR, /[^-_.!~*'()a-zA-Zа-яА-Я\d:@&=+$,;%]/.freeze)
p Rack::Mount::Utils.escape_uri("/vacancies/here/12345-по-русски")
