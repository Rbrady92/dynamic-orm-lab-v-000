require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  attr_accessor

  def initialize(columns={})
    columns.each do |prop, value|
      self.send("#{prop}=", value)
    end
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    columns = []

    table_info.each do |col|
      columns << col["name"]
    end
    columns.compact
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []

    self.class.column_names.each do |col|
      values << "'#{send(col)}'" unless send(col).nil?
    end

    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"

    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(column)
    col = column.keys[0].to_s
    value = column.values[0]

    sql = "SELECT * FROM #{table_name} WHERE #{col} = ?"

    DB[:conn].execute(sql, value)
  end

end
