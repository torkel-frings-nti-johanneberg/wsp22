require 'sqlite3'
    
class String #detta finns för att färglägaw text med asni code
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

def bookId(bNum)
    db = db_loder()
    book_id =db.execute('SELECT id FROM book WHERE number=?',bNum).first
    # puts book_id["id"].to_s.red
    return book_id["id"].to_i
end

def hej()
    puts "\e[32m______________________________________________________\e[0m"
end

def db_loder()
    db = SQLite3::Database.new("db/slut_prodj_wsp_22.db")
    db.results_as_hash = true
    
    return db
end


# addBookToPlaceInBook("mallorca",2)