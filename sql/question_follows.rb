require_relative 'questions_database.rb'

class QuestionFollow
  attr_accessor :question_id, :user_id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_follows")
    data.map { |data| QuestionFollow.new(data) }
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

  def self.followers_for_question_id(question_id)
    followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      fname, lname
    FROM
      question_follows
      JOIN users ON
        question_follows.user_id = users.id
      JOIN questions ON
        question_follows.question_id = questions.id
    WHERE
      question_id = ?
    SQL

    followers.map do |sheep|
      User.find_by_name(sheep['fname'], sheep['lname'])
    end
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      question_id
    FROM
      question_follows
      JOIN users ON
        question_follows.user_id = users.id
      JOIN questions ON
        question_follows.question_id = questions.id
    WHERE
      question_follows.user_id = ?
    SQL

    questions.map do |sheep|
      Question.find_by_id(sheep['question_id'])
    end
  end

  def self.most_followed_questions(n)
    most_followed = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT
      question_id
    FROM
      question_follows
    GROUP BY
      question_id
    ORDER BY
      count(user_id)
    LIMIT
      ?
    SQL
    most_followed.each { |q| Question.find_by_id(q['question_id']) }
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
