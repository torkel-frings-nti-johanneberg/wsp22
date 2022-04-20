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
    existing = db.execute('SELECT * FROM book_set_in_place WHERE book_id=? AND palce_id=?',book_id,place_id)
    hej(4)
    p existing
    if existing.length == 0
      db.execute('INSERT INTO book_set_in_place (book_id,palce_id) VALUES (?,?)',book_id,place_id)
      if newPlase
          db.execute('INSERT INTO places (name) VALUES (?)',place)
      end
    else
      redirect("/error")
    end

    
end

def addPerson(person,book_id)
  person = person.capitalize()
  db = db_loder()
  pepol_id = db.execute('SELECT id FROM pepol').last
  # hej()
  # hej()
  # hej()
  # p pepol_id
  pepol_id = pepol_id["id"] + 1
  # p pepol_id
  listOfPepol = db.execute('SELECT name FROM pepol')
  # p listOfPepol
  newPerson = true
  listOfPepol.each do |oldpepol|
      # p "______________________________-"
      # p oldpepol["name"] == person
      # p oldpepol["name"] 
      # p person
      if oldpepol["name"] == person 
          pepol_id = db.execute('SELECT id FROM pepol WHERE name IS ?',person).first
          pepol_id = pepol_id["id"]
          newPerson = false
      end
  end
  # p place_id
  existing = db.execute('SELECT * FROM pepol_in_book WHERE book_id=? AND pepol_id=?',book_id,pepol_id)
  hej(4)
  p existing
  if existing.length == 0
    db.execute('INSERT INTO pepol_in_book (book_id,pepol_id) VALUES (?,?)',book_id,pepol_id)
    if newPerson
        db.execute('INSERT INTO pepol (name) VALUES (?)',person)
    end
  else
    redirect to("/error")
  end
end

def removePerson(person,book_id)
  person = person.capitalize()
  db = db_loder()
  listOfPepol = db.execute('SELECT name FROM pepol')

  listOfPepol.each do |oldpepol|
    if oldpepol["name"] == person
      pepol_id = db.execute('SELECT id FROM pepol WHERE name IS ?',person).first
      hej(2)
      p pepol_id["id"]
      pepol_id = pepol_id["id"]
      p book_id
      db.execute('DELETE FROM pepol_in_book WHERE book_id=? AND pepol_id=?',book_id,pepol_id)
    end
  end

  redirect("/home")
end

def removePlace(place,book_id)
  place = place.capitalize()
  db = db_loder()
  listOfPlaces = db.execute('SELECT name FROM places')

  listOfPlaces.each do |oldplaces|
    if oldplaces["name"] == place
      place_id = db.execute('SELECT id FROM places WHERE name IS ?',place).first
      # hej(2)

      place_id = place_id["id"]

      db.execute('DELETE FROM book_set_in_place WHERE book_id=? AND palce_id=?',book_id,place_id)
    end
  end

  
end


def bookId(bNum)
    db = db_loder()
    book_id =db.execute('SELECT id FROM book WHERE number=?',bNum).first
    # puts book_id["id"].to_s.red
    return book_id["id"].to_i
end

def addbook(title, number, publiDate, posionsDrunk, piratShipSunk, boar, menhirs, artist)
  db = db_loder()
  book_id =db.execute('SELECT id FROM book').last
  book_id = book_id["id"]


  # get artist_id
  artists = db.execute("SELECT * FROM artist")
  artists_id = 0
  cunrentArtist = artist
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

  redirect("/home")
end

def getBooksInfo()
  db = db_loder()
  @booklist = db.execute("SELECT * FROM book")
  @booklist.each do |book|
    artistName = db.execute("SELECT name FROM artist WHERE id = ?", book["artist_id"])
    book["artist"] = artistName[0]["name"]
  end
  p @booklist
end

def getBookInfo(id)
  db = db_loder()
  @bookinfo = db.execute("SELECT * FROM book WHERE id=?",id)
  artistName = db.execute("SELECT name FROM artist WHERE id = ?", @bookinfo[0]["artist_id"])
  @bookinfo[0]["artist"] = artistName[0]["name"]
  hej(5)
  p @bookinfo
  hej(2)
end

def hej(iterasion)
    for i in 0...iterasion do
      puts "\e[32m______________________________________________________\e[0m"
    end
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
    # {level: 1, href: '<a href="/place/edit"> chose a place to edit</a>'},
    # {level: 1, href: '<a href="/pepol/edit"> chose a pepol to edit</a>'},
    {level: 2, href: '<a href="/rool/update"> chose a user to promot</a>'},
    {level: 3, href: '<a href="/rool/edit"> chose a user whoms roll to change</a>'},
    {level: 4, href: '<a href="/user/edit"> chose a user to edit</a>'}
  ]
  all = ["writer","editor","promoter","moderator","admin"]

  routs = allrouts.select {|item| item[:level] <= all.index(rool) }.map! do |item|
    item[:href]
  end
end

def rolllrvel()
  rool= session[:rool]
  all = ["writer","editor","promoter","moderator","admin"]
  return all.index(rool)
end

def editbook(title, number, publiDate, posionsDrunk, piratShipSunk, boar, menhirs, artist, book_id)
  db = db_loder()

  # get artist_id
  artists = db.execute("SELECT * FROM artist")
  artists_id = 0
  cunrentArtist = artist
  artists.each do |artist|
      if artist["name"] == cunrentArtist
          artists_id = artist["id"]
      end
  end
  if artists_id == 0
      redirect("/error")
  end 

  db.execute("UPDATE book SET title=?, number=?, publish_date=?, posions_drunk=?, pirat_ship_shunk=?, wild_boar=?, menhirs=?, artist_id= ? WHERE id=?", title, number, publiDate, posionsDrunk, piratShipSunk, boar, menhirs, artists_id, book_id)

  redirect("/home")
end

def editLinks()
  hachOfBooks = getBooksInfo()
  @bookHrefs = []
  hej(1)
  p hachOfBooks
  hachOfBooks.each do |book|
      @bookHrefs << "<a href=\"/books/#{book["id"]}/edit\">Edit: #{book["title"]}</a>" 
  end
end

def promote(user_id)
  db = db_loder()
  db.execute('UPDATE user SET rool="writer" WHERE id=?',user_id)

  redirect("/home")
end

def moderate(user_id,newRool)
  db = db_loder()
  db.execute('UPDATE user SET rool=? WHERE id=?',newRool,user_id)

  redirect("/home")

end

def getReaderList()
  db= db_loder()
  allrouts = []
  list = db.execute('SELECT name,id FROM user WHERE rool = "reader"')
  list.each do |user|
    allrouts << "<a href='/rool/#{user["id"]}/update'>#{user["name"]} </a>"
  end
  return allrouts
end

def getUserList()
  db = db_loder()
  allrouts = []
  @userlist = db.execute('SELECT * FROM user')
  @userlist.each do |user|
    if user["rool"] != "admin"
      allrouts << "<form action='/rool/#{user["id"]}/update' method='post'><label for=#{user["name"]}>Choose a rool for #{user["name"]}:</label><select id=#{user["id"]} name='rool' size='5' multiple><option value='reader'>reader</option><option value='writer'>writer</option><option value='editor'>editor</option><option value='promoter'>promoter</option><option value='moderator'>moderator</option></select><input type='submit'><br></form>"
    end
  end
  hej(2)
  puts allrouts
  hej(2)
  return allrouts
end

def deletUser(user_id)
  db = db_loder()
  db.execute('DELETE FROM user WHERE id=?',user_id)
end

def register(username,password,password_confirm)
  db = db_loder()
  rool = "reader"
  users = db.execute('SELECT * FROM user')

  users.each do |user|
    if username == user["name"]
      redirect("/error")
    end
  end

  if password == password_confirm
      password_digest = BCrypt::Password.create(password_confirm)
      db = db_loder()
      
      db.execute("INSERT INTO user (name, pasword,rool) VALUES(?,?,?)", username, password_digest, rool)
      login(username,password)
  else
      redirect("/error")
  end
end


def login(username,password)
  db = db_loder()
  result = db.execute("SELECT * FROM user WHERE name = ?",username).first
  if result == nil
      redirect to('/error')
  end
  pwdigets = result["pasword"]
  id = result["id"]
  hej(1)
  p result
  hej(1)
  if BCrypt::Password.new(pwdigets) == password
      p id
      session[:id] = id
      session[:rool] = result["rool"]
      p session[:rool]
      p session[:id]
      redirect('/home')
  else
      redirect to("/error")
  end
end

def numerOfBooks()
  db = db_loder()
  return db.execute('SELECT COUNT(*) FROM book')
  
end