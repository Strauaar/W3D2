require 'active_support/inflector'

class SuperClass

  def self.all(table_name, classe)
    data = QuestionsDatabase.instance.execute("SELECT * FROM #{table_name}")
    data.map { |datum| classe.new(datum) }
  end

  def self.find_by_id(id, classe, table_name)
    query = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      #{self.to_s.tableize}
    WHERE
      id = ?
    SQL
    puts self
    puts self.to_s.tableize
    self.new(query.first)
  end

end
