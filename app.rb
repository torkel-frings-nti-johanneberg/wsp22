require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require_relative 'model.rb'

get ('/') do
    hej()
    slim(:"home")

end

get ('/books') do
    db = db_loder()
    @booklist = db.execute("SELECT title,number FROM book")
    slim(:"book/index")
end

get ('/book/new') do
    slim(:"book/new")
end

get ('/place/new') do
    slim(:"place/new")
end

post ('/places') do
    book_num = params[:book]

    book_id = bookId(book_num)
    places = params[:places]
    places = places.split("\n")
    # p "_____________________"
    places.map! {|place| place.chomp}
    # p places
    # p "_____________________"
    
    places.each do |place|
        addPlace(place,book_id)
    end
    redirect("/")
end

post ('/books') do
    title =  params[:title]
    number =  params[:number]
    publiDate = params[:pub_date]
    posionsDrunk = params[:potions]
    piratShipSunk = params[:pirats]
    boar = params[:boar]
    menhirs = params[:stone]
    place = params[:place]

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

get ('/error') do
    slim(:error)
end

def db_loder()
    db = SQLite3::Database.new("db/slut_prodj_wsp_22.db")
    db.results_as_hash = true
    
    return db
end