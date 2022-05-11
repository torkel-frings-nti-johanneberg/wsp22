
require 'sqlite3'

#
# everything is awesome (lego the movie)
#
module Model
  
  #
  # Adds a place to a book and placerelasion, if it is a new place it also adds the place in the place tabel
  #
  # @param [String] place, the place to add
  # @param [Integer] book_id, the books id
  #
  # @return [Bool] fail or not
  #
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

      existing = db.execute('SELECT * FROM book_set_in_place WHERE book_id=? AND palce_id=?',book_id,place_id)
  
      if existing.length == 0
        db.execute('INSERT INTO book_set_in_place (book_id,palce_id) VALUES (?,?)',book_id,place_id)
        if newPlase
            db.execute('INSERT INTO places (name) VALUES (?)',place)
        end
      else
        return true
      end

      return false
  end

  #
  # adds a person and book relation, if the person is new its added to the pepole-list
  #
  # @param [String] person, the name of the person to add
  # @param [Integer] book_id, the books id
  #
  # @return [bool] fail or not
  #
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

    existing = db.execute('SELECT * FROM pepol_in_book WHERE book_id=? AND pepol_id=?',book_id,pepol_id)


    if existing.length == 0
      db.execute('INSERT INTO pepol_in_book (book_id,pepol_id) VALUES (?,?)',book_id,pepol_id)
      if newPerson
          db.execute('INSERT INTO pepol (name) VALUES (?)',person)
      end
    else
      return false
    end
    return true
  end

  #
  # removes a person book relation
  #
  # @param [String] person, the name of the person
  # @param [Integer] book_id, the books id

  #
  def removePerson(person,book_id)
    person = person.capitalize()
    db = db_loder()
    listOfPepol = db.execute('SELECT name FROM pepol')

    listOfPepol.each do |oldpepol|
      if oldpepol["name"] == person
        pepol_id = db.execute('SELECT id FROM pepol WHERE name IS ?',person).first


        pepol_id = pepol_id["id"]
  
        db.execute('DELETE FROM pepol_in_book WHERE book_id=? AND pepol_id=?',book_id,pepol_id)
      end
    end

    
  end

  #
  # reoves a place to book realtion
  #
  # @param [String] place, the places name
  # @param [Integer] book_id, the books id
  #
  def removePlace(place,book_id)
    place = place.capitalize()
    db = db_loder()
    listOfPlaces = db.execute('SELECT name FROM places')

    listOfPlaces.each do |oldplaces|
      if oldplaces["name"] == place
        place_id = db.execute('SELECT id FROM places WHERE name IS ?',place).first
      
        place_id = place_id["id"]

        db.execute('DELETE FROM book_set_in_place WHERE book_id=? AND palce_id=?',book_id,place_id)
      end
    end
  end


  #
  # givs the id of a book given its number
  #
  # @param [Integer] bNum the books number
  #
  # @return [Integer] the books id
  #
  def bookId(bNum)
      db = db_loder()
      book_id =db.execute('SELECT id FROM book WHERE number=?',bNum).first
    
      return book_id["id"].to_i
  end

  #
  # adds a new book to the book tabel
  #
  # @param [String] title, The books title
  # @param [Integer] number, The books number
  # @param [String] publiDate, The publich date of the book
  # @param [Integer] posionsDrunk, The amoyunt of posions drunken
  # @param [Integer] piratShipSunk, The amount of pirat Ships sunk
  # @param [Ingeger] boar, boars sen in the book
  # @param [Integer] menhirs, menhirs sen in the book
  # @param [String] artist, the artist of the book
  #
  # @return [bool] fail or not
  #
  def addbook(title, number, publiDate, posionsDrunk, piratShipSunk, boar, menhirs, artist)
    db = db_loder()
    book_id =db.execute('SELECT id FROM book').last
    book_id = book_id["id"]

    if title == "" or pub_date == "" or artist =="" or number == "" or posionsDrunk == "" or piratShipSunk == "" or boar =="" or menhirs==""
      return true
    end


    artists = db.execute("SELECT * FROM artist")
    artists_id = 0
    cunrentArtist = artist
    artists.each do |artist|
        if artist["name"] == cunrentArtist
            artists_id = artist["id"]
        end
    end
    if artists_id == 0
        return true
    end 

    
    db.execute("INSERT INTO book (title, number, publish_date,posions_drunk,pirat_ship_shunk,wild_boar,menhirs,artist_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", title, number, publiDate, posionsDrunk, piratShipSunk, boar, menhirs, artists_id)

    return false
  end

  #
  # Gets a list wht all info minus places and pepoles about all books 
  #
  def getBooksInfo()
    db = db_loder()
    @booklist = db.execute("SELECT * FROM book")
    @booklist.each do |book|
      artistName = db.execute("SELECT name FROM artist WHERE id = ?", book["artist_id"])
      book["artist"] = artistName[0]["name"]
    end
  end
  
  #
  # gets all info about one book give its id
  #
  # @param [Integer] id, the books id
  #
  def getBookInfo(id)
    db = db_loder()

    @bookinfo = db.execute("SELECT * FROM book WHERE id=?",id)
    artistName = db.execute("SELECT name FROM artist WHERE id = ?", @bookinfo[0]["artist_id"])
    @bookinfo[0]["artist"] = artistName[0]["name"]
    @bookinfo << db.execute("SELECT name FROM pepol_in_book INNER JOIN pepol ON pepol_in_book.pepol_id = pepol.id WHERE book_id = ?",id)
    @bookinfo << db.execute("SELECT name FROM book_set_in_place INNER JOIN places ON book_set_in_place.palce_id = places.id WHERE book_id = ?",id)
    

  end
 

  #
  # opens the corect databse and returns the result as hash
  #
  # @return [Hach] the databas as a hash
  #
  def db_loder()
      db = SQLite3::Database.new("db/slut_prodj_wsp_22.db")
      db.results_as_hash = true
      
      return db
  end

  #
  # Creats a array of routs that ar relervant to showe for a user loged in whit a given role
  #
  # @param [String] rool, the useracounts role
  #
  # @return [Array] a list och routs relervant to the user
  #
  def privliges(rool)
    if rool == nil
      redirect to("/")
    end
    allrouts = [
      {level: 0, href: '<a href="/book/new"> add book</a>'},
      {level: 0, href: '<a href="/place/new"> add place to book</a>'},
      {level: 0, href: '<a href="/pepol/new"> add pepol to book</a>'},
      {level: 1, href: '<a href="/book/edit"> chose a book to edit</a>'},
      {level: 2, href: '<a href="/rool/update"> chose a user to promot</a>'},
      {level: 3, href: '<a href="/rool/edit"> chose a user whoms roll to change</a>'},
      {level: 4, href: '<a href="/user/edit"> chose a user to edit</a>'}
    ]
    all = ["writer","editor","promoter","moderator","admin"]

    routs = allrouts.select {|item| item[:level] <= all.index(rool) }.map! do |item|
      item[:href]
    end

    return routs
  end

  #
  # converts a role to a level
  #
  # @param [String] rool, the user acounts role
  #
  # @return [Integer] The level of the given role
  #
  def rolllrvel(rool)

    all = ["writer","editor","promoter","moderator","admin"]
    return all.index(rool)
  end

  #
  # <Description>
  #
  # @param [String] title, The books title
  # @param [Integer] number, The books number
  # @param [String] publiDate, The publich date of the book
  # @param [Integer] posionsDrunk, The amoyunt of posions drunken
  # @param [Integer] piratShipSunk, The amount of pirat Ships sunk
  # @param [Ingeger] boar, boars sen in the book
  # @param [Integer] menhirs, menhirs sen in the book
  # @param [String] artist, the artist of the book
  # @param [Intger] book_id, the books id
  #
  # @return [bool] fail or not
  #
  def editbook(title, number, publiDate, posionsDrunk, piratShipSunk, boar, menhirs, artist, book_id)
    db = db_loder()

  
    artists = db.execute("SELECT * FROM artist")
    artists_id = 0
    cunrentArtist = artist
    artists.each do |artist|
        if artist["name"] == cunrentArtist
            artists_id = artist["id"]
        end
    end
    if artists_id == 0
        return true
    end 

    db.execute("UPDATE book SET title=?, number=?, publish_date=?, posions_drunk=?, pirat_ship_shunk=?, wild_boar=?, menhirs=?, artist_id= ? WHERE id=?", title, number, publiDate, posionsDrunk, piratShipSunk, boar, menhirs, artists_id, book_id)

    return true
  end

  #
  # A list of all books in the format of a link /book/id/edit
  #
  # @return [Array] a list of links the leght of all books in the db 
  #
  def editLinks()
    hachOfBooks = getBooksInfo()
    @bookHrefs = []


    hachOfBooks.each do |book|
        @bookHrefs << "<a href=\"/books/#{book["id"]}/edit\">Edit: #{book["title"]}</a>" 
    end
  end

  #
  # sets the role of a given user to writer
  #
  # @param [Intiger] user_id, the users id
  #
  #
  def promote(user_id)
    db = db_loder()
    db.execute('UPDATE user SET rool="writer" WHERE id=?',user_id)
  end

  #
  # change the role of a given user
  #
  # @param [Integer] user_id, the users id
  # @param [String] newRool, the new role the user wants
  #
  # @return [bool] fali or not
  def moderate(user_id,newRool)
    if newRool == ""
      return true
    end
    db = db_loder()
    db.execute('UPDATE user SET rool=? WHERE id=?',newRool,user_id)
    return false
  end

  #
  # creats a array white liks /rool/id/update for al users having role reader
  #
  # @return [Array] array of links the lengt of all users white role reader in  db
  #
  def getReaderList()
    db= db_loder()
    allrouts = []
    list = db.execute('SELECT name,id FROM user WHERE rool = "reader"')
    list.each do |user|
      allrouts << "<a href='/rool/#{user["id"]}/update'>#{user["name"]} </a>"
    end
    return allrouts
  end

  #
  # creats a array white form for al users
  #
  # @return [Array] an array whit forms to change user datta the lengt of al users minus those whit role admin
  #
  def getUserList()
    db = db_loder()
    allrouts = []
    @userlist = db.execute('SELECT * FROM user')
    @userlist.each do |user|
      if user["rool"] != "admin"
        allrouts << "<form action='/rool/#{user["id"]}/update' method='post'><label for=#{user["name"]}>Choose a rool for #{user["name"]}:</label><select id=#{user["id"]} name='rool' size='5' multiple><option value='reader'>reader</option><option value='writer'>writer</option><option value='editor'>editor</option><option value='promoter'>promoter</option><option value='moderator'>moderator</option></select><input type='submit'><br></form>"
      end
    end


    return allrouts
  end

  #
  # removes a user from user tabel
  #
  # @param [Integer] user_id,the users id
  #
  def deletUser(user_id)
    db = db_loder()
    db.execute('DELETE FROM user WHERE id=?',user_id)
  end

  #
  # creats a new user in the user tabel
  #
  # @param [String] username, the users username name
  # @param [String] password, the users password
  # @param [String] password_confirm, the users passeord agen, hoppfuly
  #
  # @return [bool] fali or not
  #
  def register(username,password,password_confirm)
    db = db_loder()
    rool = "reader"
    users = db.execute('SELECT * FROM user')

    if username == "" or passeord == "" or password_confirm == "" 
      return true
    end


    users.each do |user|
      if username == user["name"]
        return true
      end
    end

    if password == password_confirm
        password_digest = BCrypt::Password.create(password_confirm)
        db = db_loder()
        
        db.execute("INSERT INTO user (name, pasword,rool) VALUES(?,?,?)", username, password_digest, rool)
        login(username,password)
    else
        return true
    end
    return false
  end


  #
  # see if a users acount ifo is corekt to log in
  #
  # @param [String] username, the users username
  # @param [String] password, the users password
  #
  # @return [Array] containg 3 elements, first fail or not, secund user id, therd user rool
  #
  def login(username,password)
    db = db_loder()
    result = db.execute("SELECT * FROM user WHERE name = ?",username).first
    time = Time.new

    atempt = result["iAtempts"] + 1

    if time - result["lastInlog"] < 1000*60*10 #mili to sec to min  to 10min
      atempt = 0
    end

    if result == nil or atempt > 5
        db.execute("UPDATE user SET iAtempts=?",atempt)
        return [true,nil,nil]
    end
    pwdigets = result["pasword"]
    id = result["id"]

    if BCrypt::Password.new(pwdigets) == password
        db.execute("UPDATE user SET lastInlog=?, iAtempts=?",time,0)
        return [false,id,result]
    else
        db.execute("UPDATE user SET iAtempts=?",atempt)
        return [true,nil,nil]
    end
  end

  #
  # gives the number of books in the db
  # 
  # @return [Integer] the number of books in the book tabel in the db
  #
  def numerOfBooks()
    db = db_loder()
    return db.execute('SELECT COUNT(*) FROM book')
    
  end
end

