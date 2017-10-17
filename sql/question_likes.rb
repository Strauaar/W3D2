require_relative 'questions_database.rb'
require_relative 'question'
class Like
  attr_accessor :user_id, :question_id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_likes")
    data.map { |data| Like.new(data) }
  end

  def self.find_by_id(id)
    like = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      question_likes
    WHERE
      id = ?
    SQL

    Like.new(like.first)
  end

  def self.likers_for_question_id(question_id)
    likers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      user_id, fname, lname
    FROM
      users
      JOIN question_likes ON question_likes.user_id = users.id
    WHERE
      question_id = ?
    SQL
    likers.map { |user| User.find_by_id(user['user_id']) }
  end

  def self.num_likes_for_question_id(question_id)
    likes = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      count(user_id) as Likes
    FROM
      question_likes
    WHERE
      question_id = ?
    SQL
    likes.first['Likes']
  end

  def self.liked_questions_for_user_id(user_id)
    users_liked_questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      question_id
    FROM
      question_likes
    WHERE
      user_id = ?
    SQL
    users_liked_questions.map do |questionsthattheuserhasliked|
      Question.find_by_id(questionsthattheuserhasliked['question_id'])
    end
  end

  def self.most_liked_questions(n)
    liked_questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        question_id
      FROM
        question_likes
      GROUP BY
        question_id
      ORDER BY
        count(user_id) DESC
      LIMIT ?
    SQL
    liked_questions.map { |qs| Question.find_by_id(qs['question_id'])}
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options ['question_id']
  end

  def create
    raise "#{self} exists" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @user_id, @question_id)
    INSERT INTO
      question_likes (user_id, question_id)
    VALUES
      (? , ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

end
