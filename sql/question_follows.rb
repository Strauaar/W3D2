class QuestionFollow
  attr_accessor :question_id, :user_id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_follows")
    data.map { |data| Question.new(data) }
  end

  def self.find_by_id(id)
    question_follows = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      question_follows
    WHERE
      id = ?
    SQL

    QuestionFollow.new(question_follows.first)
  end

  def initialize(options)
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def create
    raise "#{self} exists" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @user_id, @question_id)
    INSERT INTO
      question_follows (user_id, question_id)
    VALUES
      (? , ?)
    SQL
  end

end
