require './src/book'
require './src/student'
require './src/teacher'
require './src/handle_data'
require './src/rental'

class App
  def initialize
    @books_data = HandleData.new('books')
    @people_data = HandleData.new('people')
    @rentals_data = HandleData.new('rentals')
    @books = @books_data.read.map { |book| Book.new(book[0], book[1]) }
    @people = @people_data.read.map do |pep|
      if pep[0] == 'Student'
        Student.new(pep[1], pep[2], parent_permission: pep[3], classroom: pep[4])
      else
        Teacher.new(pep[1], pep[2], parent_permission: pep[3], specialization: pep[4])
      end
    end
    @rentals = @rentals_data.read.map do |rental|
      book = @books.select { |bok| bok.title == rental[2] }[0]
      person = @people.select { |pep| pep.name == rental[1] }[0]
      Rental.new(rental[0], person, book)
    end
  end

  def book_list(is_printing_index: false)
    if @books.empty?
      puts 'book list is empty, try add a new book!'
    else
      @books.each_with_index do |book, index|
        if is_printing_index
          puts "#{index}) Title: \"#{book.title}\", Author: #{book.author}"
        else
          puts "Title: \"#{book.title}\", Author: #{book.author}"
        end
      end
    end
    puts "\n"
  end

  def create_book
    print 'Title: '
    title = gets.chomp
    print 'Author: '
    author = gets.chomp
    book = Book.new(title, author)
    @books.push(book)
    puts "Book created successfully!\n"
  end

  def person_list(is_printing_index: false)
    @people.each_with_index do |person, index|
      if is_printing_index
        puts "#{index}) [#{person.class}] Name: #{person.name}, ID: #{person.id}, Age: #{person.age}"
      else
        puts "[#{person.class}] Name: #{person.name}, ID: #{person.id}, Age: #{person.age}"
      end
    end
    puts "\n"
  end

  def create_person
    print 'Do you want to create a student (1) or a teacher (2)? [Input the number]: '
    num = gets.chomp
    if %w[1 2].include?(num)
      age = add_person_age
      name = add_person_name
    end
    created_person = nil
    case num
    when '1' then created_person = create_student(name, age)
    when '2' then created_person = creat_teacher(name, age)
    end
    @people.push(created_person)
    puts "Person created successfully!\n\n"
    created_person
  end

  def add_person_age
    age = 0
    temp = false
    until temp
      print 'Age: '
      age = gets.chomp.to_i
      puts 'Enter a valid number' unless age.positive?
      temp = age.positive?
    end
    age
  end

  def add_person_name
    name = ''
    checking = false
    until checking
      print 'Name: '
      name = gets.chomp
      puts 'Enter a valid name' if name.to_i.positive?
      checking = !name.to_i.positive?
    end
    name
  end

  def create_student(name, age)
    print 'Parent permisssion [y/n]:'
    permission = gets.chomp
    bool_permission = true
    bool_permission = false if %w[n N].include?(permission)
    print 'Enter classroom: '
    classroom = gets.chomp
    Student.new(name, age, parent_permission: bool_permission, classroom: classroom)
  end

  def creat_teacher(name, age)
    print 'Specialization:'
    specialization = gets.chomp
    Teacher.new(name, age, parent_permission: true, specialization: specialization)
  end

  def rental_list
    print 'ID of person: '
    id = gets.chomp.to_i
    puts 'Rentals:'
    @rentals.each do |rent|
      puts "Date: #{rent.date}, Book \"#{rent.book.title}\" by #{rent.book.author}" if rent.person.id == id
    end
    puts "\n"
  end

  def create_rental
    if @books.empty?
      puts 'No books avilable, Add a new book.'
    elsif @people.empty?
      puts 'No person avilable, Add a new person.'
    else
      puts "\nSelect a book from the following list by number"
      book_list(is_printing_index: true)
      book_id = gets.chomp.to_i

      puts "\nSelect a person from the following list by number (not id)"
      person_list(is_printing_index: true)
      person_id = gets.chomp.to_i

      print "\nDate: "
      date = gets.chomp

      rent = Rental.new(date, @people[person_id], @books[book_id])
      @rentals.push(rent)
      puts "Rental created successfully!\n\n"
    end
  end

  def save_files
    generated_books = @books.map do |book|
      [book.title, book.author]
    end
    @books_data.write(generated_books)

    generated_people = @people.map do |pep|
      if pep.instance_of?(::Student)
        [pep.class, pep.name, pep.age, pep.parent_permission, pep.classroom]
      else
        [pep.class, pep.name, pep.age, pep.parent_permission, pep.specialization]
      end
    end
    @people_data.write(generated_people)

    generated_rentals = @rentals.map do |rental|
      [rental.date, rental.person.name, rental.book.title]
    end
    @rentals_data.write(generated_rentals)
  end
end
