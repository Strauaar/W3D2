require 'sqlite3'
require 'singleton'
require_relative 'superclass'
require_relative 'question'
require_relative 'question_follows'
require_relative 'replies'
require_relative 'question_likes'


class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end

end

class User < SuperClass

  attr_accessor :fname, :lname

  def self.all
    super('users', self)
  end

  def self.find_by_id(id)
    super(id, self, 'users')
  end

  def self.find_by_name(fname, lname)
    user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
    SELECT
      *
    FROM
      users
    WHERE
      fname = ? AND lname = ?
    SQL
    User.find_by_id(user.first['id'])
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options ['lname']
  end

  def create
    raise "#{self} exists" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
    INSERT INTO
      users (fname, lname)
    VALUES
      (? , ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    Like.liked_questions_for_user_id(@id)
  end

  def average_karma
    QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        fname, lname, CAST(COUNT(question_likes.user_id)/COUNT(DISTINCT body )AS FLOAT) AS average_karma
      FROM
        users
        JOIN questions
        ON users.id = questions.user_id
        JOIN question_likes
        ON questions.id = question_likes.question_id
        GROUP BY body;
    SQL
  end


end
