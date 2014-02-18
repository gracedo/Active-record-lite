require_relative '04_associatable'

# Phase V
module Associatable
  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      
      through_table = through_options.table_name
      through_fkey = through_options.foreign_key
      through_pkey = through_options.primary_key
      
      source_table = source_options.table_name
      source_fkey = source_options.foreign_key
      source_pkey = source_options.primary_key

      key_val = self.send(through_fkey)
      query_str = <<-SQL
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table}
        ON
          #{through_table}.#{source_fkey} = #{source_table}.#{source_pkey}
        WHERE
          #{through_table}.#{through_pkey} = ?
      SQL
      
      record = DBConnection.instance.execute(query_str, key_val)
      source_options.model_class.parse_all(record).first
    end
  end
end