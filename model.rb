require 'sqlite3'
    
class String #detta finns för att färgläga text med asni code
    def colorize(color_code)
      "\e[#{color_code}m#{self}\e[0m"
    end
    def red
      colorize(31)
    end
    def green
      colorize(32)
    end
    def yellow
      colorize(33)
    end
    def blue
      colorize(34)
    end
    def pink
      colorize(35)
    end
    def light_blue
      colorize(36)
    end
end


def addPlace(place,book_id)
    place = place.capitalize()
    db = db_loder()
    place_id = db.execute('SELECT id FROM places').last
    place_id = place_id["id"] + 1
    listOfPlaces = db.execute('SELECT name FROM places')
    newPlase = true
    listOfPlaces.each do |oldplace|
        if oldplace["name"] == place
            place_id = db.execute('SELECT id FROM places WHERE name IS ?',place).first
            place_id = place_id["id"]
            newPlase = false
        end
    end
    # p place_id
    db.execute('INSERT INTO book_set_in_place (book_id,palce_id) VALUES (?,?)',book_id,place_id)
    if newPlase
        db.execute('INSERT INTO places (name) VALUES (?)',place)
    end
end

def addPerson(person,book_id)
  person = person.capitalize()
  db = db_loder()
  pepol_id = db.execute('SELECT id FROM pepol').last
  pepol_id = pepol_id["id"] + 1
  listOfPepol = db.execute('SELECT name FROM pepol')
  newPerson = true
  listOfPepol.each do |oldpepol|
      if oldpepol["name"] == person
          pepol_id = db.execute('SELECT id FROM pepol WHERE name IS ?',person).first
          pepol_id = pepol_id["id"]
          newPerson = false
      end
  end
  # p place_id
  db.execute('INSERT INTO pepol_in_book (book_id,pepol_id) VALUES (?,?)',book_id,pepol_id)
  if newPlase
      db.execute('INSERT INTO pepol (name) VALUES (?)',person)
  end
end

def bookId(bNum)
    db = db_loder()
    book_id =db.execute('SELECT id FROM book WHERE number=?',bNum).first
    # puts book_id["id"].to_s.red
    return book_id["id"].to_i
end

def addbook(title, number, publiDate, posionsDrunk, piratShipSunk, boar, menhirs)
  db = db_loder()
  book_id =db.execute('SELECT id FROM book').last
  book_id = book_id["id"]


  # get artist_id
  artists = db.execute("SELECT * FROM artist")
  artists_id = 0
  cunrentArtist = params[:artist]
  artists.each do |artist|
      if artist["name"] == cunrentArtist
          artists_id = artist["id"]
      end
  end
  if artists_id == 0
      redirect("/error")
  end 

  # add book info to db
  db.execute("INSERT INTO book (title, number, publish_date,posions_drunk,pirat_ship_shunk,wild_boar,menhirs,artist_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", title, number, publiDate, posionsDrunk, piratShipSunk, boar, menhirs, artists_id)

  redirect("/")
end

def getTittleNumberBooks()
  db = db_loder()
  @booklist = db.execute("SELECT title,number FROM book")
end

def hej()
    puts "\e[32m______________________________________________________\e[0m"
end

def db_loder()
    db = SQLite3::Database.new("db/slut_prodj_wsp_22.db")
    db.results_as_hash = true
    
    return db
end

def privliges(rool)
  allrouts = [
    {level: 0, href: '<a href="/book/new"> add book</a>'},
    {level: 0, href: '<a href="/place/new"> add place to book</a>'},
    {level: 0, href: '<a href="/pepol/new"> add pepol to book</a>'},
    {level: 1, href: '<a href="/book/edit"> chose a book to edit</a>'},
    {level: 1, href: '<a href="/place/edit"> chose a place to edit</a>'},
    {level: 1, href: '<a href="/pepol/edit"> chose a pepol to edit</a>'},
    {level: 2, href: '<a href="/rool/update"> chose a user to promot</a>'},
    {level: 3, href: '<a href="/rool/edit"> chose a user whoms roll to change</a>'},
    {level: 4, href: '<a href="/rool/edit"> chose a user to edit</a>'}
  ]
  all = ["writer","editor","promoter","moderator","admin"]

  routs = allrouts.select {|item| item[:level] <= all.index(rool) }.map! do |item|
    item[:href]
  end


end

# puts privliges("sdfhkl")


# addBookToPlaceInBook("mallorca",2)