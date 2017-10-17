DROP TABLE users;
DROP TABLE questions;
DROP TABLE question_follows;
DROP TABLE replies;
DROP TABLE question_likes;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body VARCHAR(255),
  user_id INTEGER,

  FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  question_id INTEGER,
  user_id INTEGER,

  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  parent_reply_id INTEGER,
  body VARCHAR(255),
  question_id INTEGER,

  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(question_id) REFERENCES questions(id),
  FOREIGN KEY(parent_reply_id) REFERENCES replies(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  question_id INTEGER,

  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(question_id) REFERENCES questions(id)
);

INSERT INTO
  users(fname, lname)
VALUES
  ('Maliha', 'Syed'),
  ('Aaron', 'Strauli'),
  ('John', 'Doe'),
  ('IMMA', 'lnameFROm_TABLE');

INSERT INTO
  questions(title, body, user_id)
VALUES
  ('SQL', 'How do I pronounce SQL?', 1),
  ('Fridge', 'Where can I find the desserts?', 2),
  ('Existential Crisis', 'Why do I appear in everyone''s life?', 3);
