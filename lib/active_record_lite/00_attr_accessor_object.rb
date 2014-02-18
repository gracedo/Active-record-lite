class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      define_method(name) { name.instance_variable_get(:@name) }
    end
    
    names.each do |name|
      define_method("#{name}=") { |new_val| name.instance_variable_set(:@name, new_val) }
    end
  end
end