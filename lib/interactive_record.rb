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
    columnns.compact
  end

  def self.table_name_for_insert
    self.class.table_name
  end

  def self.column_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

end
