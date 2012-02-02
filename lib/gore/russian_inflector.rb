module Gore::RussianInflector
	def self.inflect(number, word, end1, end2, end5, strategy = :normal)
		number_by_100 = number % 100
	  ending = case strategy
		when :normal
			case number_by_100
			when 1 then end1
			when 2..4 then end2
			when 5..20 then end5
			else
				case number_by_100 % 10
				when 1 then end1
				when 2..4 then end2
				when 0, 5..9 then end5
				end
			end
		when :more
			case number_by_100
			when 1 then end2
			when 2..20 then end5
			else
				case number_by_100 % 10
				when 1 then end2
				when 0, 2..9 then end5
				end
			end	
		end
		word + ending
	end	
	
	def self.parameterize(string, sep = "-")
    string ||= ""

	  parameterized_string = UnicodeUtils.downcase(string).gsub(/[^a-z0-9\u0430-\u044f\-_]+/i, sep)

	  if sep.present?
      re_sep = Regexp.escape(sep)
      parameterized_string.gsub!(/#{re_sep}{2,}/, sep)
      parameterized_string.gsub!(/^#{re_sep}|#{re_sep}$/i, '')
    end
    
    parameterized_string
	end
end

if $0 == __FILE__
	1.upto(150) do |i|
		print "#{i} "
		print Gore::RussianInflector.inflect(i, 'ваканс', 'ия', 'ии', 'ий' )
		print "\n"
	end

	1.upto(150) do |i|
		print "более #{i} "
		print Gore::RussianInflector.inflect(i, 'ваканс', 'ия', 'ии', 'ий', :more)
		print "\n"
	end
end
