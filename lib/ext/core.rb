class Object
  def _class
    self.class
  end
  
  def is?(*types)
    types.any? { |type| self.is_a?(type) }
  end

  # joe.send_chain 'name.last' #=> 'Smith'
  def send_chain(expression)
    expression = expression.to_s
    return self if expression.blank?
    return self.send(expression) unless expression.include?(".")
    
    expression.split('.').inject(self) { |result, method| result.send(method) }
  end
  
  def assign_attributes(attributes)
    attributes.each_pair { |k,v| send("#{k}=", v) if respond_to?("#{k}=") } if attributes
  end  

  def assign_attributes!(attributes)
    attributes.each_pair { |k,v| send("#{k}=", v) } if attributes
  end  
end

module Enumerable
  # ary.select { |val| val.to_i == 3 }
  # ary.select_eq(to_i: 3)
  def select_eq(params = {})
    params = params.to_a
    select { |obj| params.all? { |k,v| obj.send(k) == v } }
  end

  def select_neq(params)
    params = params.to_a
    select { |obj| params.all? { |k,v| obj.send(k) != v } }
  end

  def select_in(params)
    params = params.to_a
    select { |obj| params.all? { |k,v| obj.send(k).in?(v) } }
  end

  def select_nin(params)
    params = params.to_a
    select { |obj| params.all? { |k,v| !obj.send(k).in?(v) } }
  end
  
  def detect_eq(params = {})
    params = params.to_a
    detect { |obj| params.all? { |k,v| obj.send(k) == v } }
  end

  def detect_neq(params)
    params = params.to_a
    detect { |obj| params.all? { |k,v| obj.send(k) != v } }
  end  
  
  def send_each(method, *args, &block)
    each { |obj| obj.send(method, *args, &block) }
  end
  
  def map_to_array(*attrs)
    map { |obj| attrs.inject([]) { |array, attr| array << obj.send(attr) } }
  end

  def pluck(attr)
    map { |obj| obj.send(attr) }
  end
  
  def pluck_all(attr)
    map { |args| args.map(&attr) }
  end
end

class Module
  def def_struct_ctor
    module_eval <<-RUBY
      def intialize(attributes = {})
        assign_attributes!(attributes)
        super
      end
    RUBY
  end
  
  def def_state_predicates(storage, *states)
    module_eval <<-RUBY
      def self._state_attr
        :#{storage}
      end
      
      def self._states
        [ #{states.map { |state| ":#{state}" }.join(',')} ]
      end      
    RUBY
    
    states.each do |state|
      module_eval <<-RUBY
        def #{state}?
          self.#{storage} == :#{state} || self.#{storage} == '#{state}'
        end
      RUBY
    end
  end  
end

class Hash
  def append_string(key, text)
    self[key] ||= ""
    self[key] = self[key].present?? self[key] + ' ' + text.to_s : text.to_s
  end

  def prepend_string(key, text)
    self[key] ||= ""
    self[key] = self[key].present?? text.to_s + ' ' + self[key] : text.to_s
  end
end

# class Time
#   def to_json(*args)
#     as_json.to_json
#   end
# end
# 
# class BSON::ObjectId
#   def to_json(*args)
#     as_json.to_json
#   end  
# end

class File
  def self.write(path, data = nil)
    Log.trace "Writing file #{path} (#{data.try(:size)}bytes)"
    open(path, 'w') { |file| file << data }
  end  
end
