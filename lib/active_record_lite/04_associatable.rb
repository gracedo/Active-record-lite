require_relative '03_searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key,
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = (options[:foreign_key] || (name.to_s + '_id').to_sym)
    @class_name = (options[:class_name] || name.to_s.camelcase)
    @primary_key = (options[:primary_key] || :id)
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = (options[:foreign_key] || (self_class_name.to_s.underscore + '_id').to_sym)
    @class_name = (options[:class_name] || name.to_s.singularize.camelcase)
    @primary_key = (options[:primary_key] || :id)
  end
end

module Associatable
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)
    
    define_method(name) do
      options = self.class.assoc_options[name]
      target_keyval = self.send(options.foreign_key)
      target_class = options.model_class
      target_class.where({options.primary_key => target_keyval}).first
    end
  end

  def has_many(name, options = {})
    self.assoc_options[name] = HasManyOptions.new(name, self.name, options)
    
    define_method(name) do
      options = self.class.assoc_options[name]
      target_keyval = self.send(options.primary_key)
      target_class = options.model_class
      target_class.where({options.foreign_key => target_keyval})
    end
  end

  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end
end

class SQLObject
  extend Associatable
end
