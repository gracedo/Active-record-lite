require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
    where_line = params.map do |key, val|
      "#{key} = ?"
    end.join(" AND ")
    
    hashes = DBConnection.instance.execute("SELECT * FROM #{self.table_name} WHERE #{where_line}", *params.values)
    parse_all(hashes)
  end
end

class SQLObject
  extend Searchable
end
