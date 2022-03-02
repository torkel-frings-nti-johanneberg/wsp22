
require 'sqlite3'
    
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
    p place_id
    db.execute('INSERT INTO book_set_in_place (book_id,palce_id) VALUES (?,?)',book_id,place_id)
    if newPlase
        db.execute('INSERT INTO places (name) VALUES (?)',place)
    end
end




def db_loder()
    db = SQLite3::Database.new("db/slut_prodj_wsp_22.db")
    db.results_as_hash = true
    
    return db
end


addBookToPlaceInBook("mallorca",2)