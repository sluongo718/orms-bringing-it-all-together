
require 'pry'

class Dog
    attr_accessor :name, :breed, :id

    def initialize(arguments)
        
        arguments.each do |arg|
            if arg[0] == :name
                @name = arg[1]
            else
                @breed = arg[1]
            end
        end
        @id = nil
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        );
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE IF EXISTS dogs
        SQL

        DB[:conn].execute(sql)
    end

    def save
        if !self.id
            sql = <<-SQL
            INSERT INTO dogs (name, breed) 
            VALUES (?, ?)
            SQL

            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(arguments)
        dog = Dog.new(arguments)
        dog.save
        dog
    end

    def self.new_from_db(db)
        arguments = {}
        id = nil
        name = nil
        breed = nil
        db.each do |dog|
            if id == nil
                id = dog
            elsif id != nil && name == nil
                name = dog
            else
                breed = dog
            end
        end
        arguments = {name: name, breed: breed}
        pup = Dog.new(arguments)
        pup.id = id
        pup
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
        SQL

        dog = DB[:conn].execute(sql, id).flatten
        pup = Dog.new_from_db(dog)
        pup
    end

    def self.find_or_create_by(arguments)
        name = nil
        breed = nil
        arguments.each do |arg|
            if arg[0] == :name
                name = arg[1]
            else
                breed = arg[1]
            end
        end

        pup = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        pup_data = pup[0]
        
        if !pup.empty?
            dog = Dog.new_from_db(pup_data)
        else
            dog = Dog.create(:name => name, :breed => breed)

        end

        dog        
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
        SQL

        dog = DB[:conn].execute(sql, name).flatten
        pup = Dog.new_from_db(dog)
        pup
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end