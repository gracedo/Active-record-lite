require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    results.map { |record| self.new(record) }
  end
end

class SQLObject < MassObject
  def self.columns
    col_names = DBConnection.instance.execute2("SELECT * FROM #{@table_name}").first
    
    col_names.each do |col|
      define_method(col) { @attributes[col.to_sym] }
      define_method("#{col}=") { |new_val| @attributes[col.to_sym] = new_val }
    end

    return col_names
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.underscore.pluralize
  end

  def self.all
    all_records = DBConnection.instance.execute("SELECT * FROM #{@table_name}")
    parse_all(all_records)
  end

  def self.find(id)
    obj_data = DBConnection.instance.execute("SELECT * FROM #{table_name} t WHERE t.id = ?", id)
    parse_all(obj_data).first
  end

  def attributes
    @attributes ||= {}
  end

  def insert
    col_names = @attributes.keys.join(', ')
    q_marks = (["?"] * @attributes.keys.length).join(', ')
    
    DBConnection.instance.execute("INSERT INTO #{self.class.table_name} (#{col_names}) VALUES (#{q_marks})", *attribute_values)
    self.id = DBConnection.last_insert_row_id
  end

  def initialize(params = {})
    attributes # initialize attributes instance variable
    
    params.each do |attr_name, value|
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_name.to_s)
      attr_name = attr_name.to_sym
      @attributes[attr_name] = value
    end
  end

  def save
    self.id.nil? ? insert : update
  end

  def update
    cols = @attributes.map do |col, val|
      "#{col} = ?"
    end.join(', ')
    
    DBConnection.instance.execute("UPDATE #{self.class.table_name} SET #{cols} WHERE #{self.class.table_name}.id = ?", *attribute_values, self.id)
  end

  def attribute_values
    @attributes.keys.map { |col| self.send(col) }
  end
end