require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade, :id
  def initialize id = nil, name, grade
    @id = id
    @name = name
    @grade = grade
  end
  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end
  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students;
    SQL
    DB[:conn].execute(sql)
  end
  def update
    DB[:conn].execute("UPDATE students SET name = ?, grade = ? WHERE id = ?", self.name, self.grade, self.id)
  end
  def save 
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?);
      SQL
      DB[:conn].execute(sql, self.name, self.grade)

      self.id = DB[:conn].execute("SELECT * FROM students WHERE name = ?", self.name)[0][0]

      self
    end
  end
  def self.create name, grade
    new_student = self.new(name, grade)
    new_student.save
  end
  def self.new_from_db query_result
    self.new(query_result[0], query_result[1], query_result[2])
  end
  def self.find_by_name name
    sql = "SELECT * FROM students WHERE name = ?"
    self.new_from_db(DB[:conn].execute(sql, name)[0])
  end
end
