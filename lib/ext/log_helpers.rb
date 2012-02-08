# # __w(customer.name, "Customer") => /// Customer = "Joe"
# # __w(customer.name) => /// "Joe"
# def __w(object, comment = nil)
#   comment &&= "#{comment} = "
#   inspection = PP.pp(object, StringIO.new, 100).string rescue object.inspect
#   Rails.logger.debug("/// #{comment}#{inspection}")
# end
# 
# # __d(customer.name, binding) => /// customer.name = "Joe"
# # __d(@customer.name) => /// @customer.name = "Joe"
# def __d(expression, binding = nil)
#   value = eval(expression.to_s, binding)
#   __w(value, expression.to_s)
# end
# 
def __p(*messages)
  puts "/// #{messages.inspect}"
end

def __pl(label, data)
  puts "/// #{label} = #{data.inspect}"
end

# def __pl(*args)
#   location = Gore.reformat_caller(caller.first)
#   puts "/// #{location} -- #{args.inspect}"
# end
# 
# def __l(*args)
#   text = args.length == 1 && String === args.first ? args.first : args.map(&:inspect).join(", ")
#   Log.trace "/// #{text}"
# end
# 
# def __ll(*args)
#   location = Gore.reformat_caller(caller.first)
#   Log.trace "/// #{location} -- #{args.map(&:inspect).join(", ")}"
# end

def __t(*args)
  puts "  TRACE - #{caller.first} #{args.inspect}" 
end      
