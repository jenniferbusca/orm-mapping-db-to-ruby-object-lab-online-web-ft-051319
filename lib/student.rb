class Student
  attr_accessor :id, :name, :grade

  def self.new_from_db(row)
    new_student = self.new
    new_student.id = row[0]
    new_student.name =  row[1]
    new_student.grade = row[2]
    new_student  # return the newly created instance
  end

  def self.all
    sql = <<-SQL
      SELECT *
      FROM students
    SQL

    DB[:conn].execute(sql).map do |row| # iteration over the hash in the environment file to access each row
      self.new_from_db(row) #calling new_from_db on each row
    end
  end

  def self.all_students_in_grade_9
    self.all.select {|student| student.grade == 9}
  end

  def self.students_below_12th_grade
    self.all.select {|student| student.grade < 12}
  end

  def self.first_X_students_in_grade_10(x)
    self.all.select {|student| student.grade == 10 && student.id <= x}
  end

  def self.first_student_in_grade_10
    self.all.select {|student| student.grade == 10}.first
  end

  def self.all_students_in_grade_X(x)
    self.all.select {|student| student.grade == x}
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row| #The return value of the .map method is an array, and we're simply grabbing the .first element from the returned array.
      self.new_from_db(row)
    end.first
  end

  def save
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end
end
