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
      #{table_name}
    WHERE
      id = ?
    SQL

    classe.new(query.first)
  end

end
