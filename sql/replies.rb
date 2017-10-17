require_relative 'questions_database.rb'
require 'byebug'
class Reply
  attr_accessor :user_id, :parent_reply_id, :body, :question_id

  def self.all
    reply = QuestionsDatabase.instance.execute("SELECT * FROM replies")
    reply.map { |data| Reply.new(data) }
  end

  def self.find_by_id(id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      replies
    WHERE
      id = ?
    SQL

    Reply.new(reply.first)
  end

  def self.find_by_user_id(user_id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      *
    FROM
      replies
    WHERE
      user_id = ?
    SQL
    reply.map { |replies_hsh| Reply.find_by_id(replies_hsh['id'])}
  end

  def self.find_by_question_id(question_id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      *
    FROM
     replies
    WHERE
      question_id = ?
    SQL
    Reply.find_by_id(reply.first['id'])
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @parent_reply_id = options['parent_reply_id']
    @body = options['body']
    @question_id = options['question_id']
  end

  def create
    raise "#{self} exists" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @user_id, @parent_reply_id, @body, @question_id)
    INSERT INTO
      replies (user_id, parent_reply_id, body, question_id)
    VALUES
      (? , ?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def author
    User.find_by_id(@user_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    Reply.find_by_id(@parent_reply_id)
  end

  def child_replies
    childs = QuestionsDatabase.instance.execute(<<-SQL)
    SELECT
      *
    FROM
      replies
    WHERE
      parent_reply_id = @id
    SQL
    childs.map{ |child| Reply.find_by_id(child['id']) }
  end

end
