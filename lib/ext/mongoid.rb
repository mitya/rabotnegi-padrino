module MongoidPagination
  extend ActiveSupport::Concern

  included do
    def self.paginate(page_num, page_size = 10)
      criteria = page(page_num, page_size)
      results = criteria.to_a
      results.extend(MongoidPagination::Collection)
      results.criteria = criteria
      results.total_count = criteria.count
      results
    end

    scope :page, proc { |page_num, page_size = 10| limit(page_size).offset(page_size * ([page_num.to_i, 1].max - 1)) } do
      include MongoidPagination::Collection
    end
  end

  module Collection
    def criteria
      @criteria || self
    end

    def criteria=(object)
      @criteria = object
    end

    def limit_value
      criteria.options[:limit]
    end

    def offset_value
      criteria.options[:skip]
    end

    def total_count
      @total_count ||= criteria.count
    end
    
    def total_count=(value)
      @total_count = value
    end

    def per(num)
      if (n = num.to_i) <= 0
        self
      else
        limit(n).offset(offset_value / limit_value * n)
      end
    end

    # Total number of pages
    def num_pages
      (total_count.to_f / limit_value).ceil
    end

    alias total_pages num_pages

    # Current page number
    def current_page
      (offset_value / limit_value) + 1
    end

    # First page of the collection ?
    def first_page?
      current_page == 1
    end

    # Last page of the collection?
    def last_page?
      current_page >= num_pages
    end    

    # current_page - 1 or nil if there is no previous page
    def previous_page
      current_page > 1 ? (current_page - 1) : nil
    end

    # current_page + 1 or nil if there is no next page
    def next_page
      current_page < total_pages ? (current_page + 1) : nil
    end    
  end
end

module Mongoid::Document
  def store(attributes = {})
    update_attributes!(attributes)
  end  

  def mark(state, other_attributes = {})
    self[self.class._state_attr] = state
    self["#{state}_at"] = Time.now
    update_attributes!(other_attributes)
  end
  
  def update_if_stored!(attributes = {})
    self.attributes = attributes
    save! unless new?
  end  
    
  module ClassMethods
    def get(id)
      find(id)
    end
    
    def def_state_predicates(storage, *states)
      super
      states.each { |state| field "#{state}_at", type: Time }    
    end 
    
    def no_update_tracking
      class_eval <<-ruby
        def set_updated_at      
        end      
      ruby
    end
  end
  
  include MongoidPagination
end
