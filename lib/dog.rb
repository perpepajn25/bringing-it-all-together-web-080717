require 'pry'
class Dog

  attr_accessor :id, :name, :breed

  def initialize(id:nil, name:,breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
      id = row[0]
      name = row[1]
      breed = row[2]
    self.new(id: id, name: name, breed: breed )
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL
    row = DB[:conn].execute(sql,name).flatten
    self.new_from_db(row)
  end

  def self.create(hash)
    dog = self.new(hash)
    dog.save
    dog
  end

  def save
    unless self.id
      sql = <<-SQL
      INSERT INTO dogs (name,breed) VALUES (?,?)
      SQL
      DB[:conn].execute(sql,self.name,self.breed).flatten
      value= DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten
      self.id = value[0]
      self
    end
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL
    row = DB[:conn].execute(sql,id).flatten
    self.new_from_db(row)
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1
    SQL
    row = DB[:conn].execute(sql,hash[:name],hash[:breed]).flatten
    if row.length == 0
      self.create(hash)
    else
      self.new_from_db(row)
    end
  end

  def update
     sql = <<-SQL
     UPDATE dogs SET name = ?, breed = ? WHERE id = ?
     SQL
     DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
