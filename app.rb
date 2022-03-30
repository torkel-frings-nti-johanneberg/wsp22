require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require "bcrypt"
require_relative 'model.rb'

enable :sessions

get('/') do 
    session[:rool] = "reader"
    redirect('/home')
end

get('/home') do
    hej()
    slim(:"home")
end

get ('/books') do
    getTittleNumberBooks()
    slim(:"book/index")
end

get ('/book/new') do
    slim(:"book/new")
end

get ('/place/new') do
    slim(:"place/new")
end

get ('/pepol/new') do
    slim(:"pepol/new")
end

post ('/places') do
    book_num = params[:book]

    book_id = bookId(book_num)
    places = params[:places]
    places = places.split("\n")
    places.map! {|place| place.chomp}
    places.each do |place|
        addPlace(place,book_id)
    end
    redirect("/home")
end

post ('/pepol') do
    book_num = params[:book]

    book_id = bookId(book_num)
    pepol = params[:pepol]
    pepol = pepol.split("\n")
    # p "_____________________"
    pepol.map! {|person| person.chomp}
    # p places
    # p "_____________________"
    
    pepol.each do |person|
        addPerson(person,book_id)
    end
    redirect("/home")
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

    addbooks(title, number, publiDate, posionsDrunk, piratShipSunk, boar, menhirs)
end

get("/login") do
    slim(:"users/login")
end

get("/register") do
    slim(:"users/regsister")
end

get("/logout") do
    session.destroy
    redirect('/')
end
  
post("/login") do
    username = params[:username]
    password = params[:password]
    db = db_loder()
    result = db.execute("SELECT * FROM user WHERE name = ?",username).first
    pwdigets = result["pasword"]
    id = result["id"]
    hej()
    p result
    hej()
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
  
post("/users") do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_connfirm]
    rool = "reader"
    
    if password == password_confirm
        password_digest = BCrypt::Password.create(password_confirm)
        db = db_loder()
        
        db.execute("INSERT INTO user (name, pasword,rool) VALUES(?,?,?)", username, password_digest, rool)
        redirect("/home")
    else
        redirect("/error")
    end
end

get ('/error') do
    slim(:error)
end

def db_loder()
    db = SQLite3::Database.new("db/slut_prodj_wsp_22.db")
    db.results_as_hash = true
    
    return db
end