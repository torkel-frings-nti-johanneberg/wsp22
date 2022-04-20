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
    hej(1)
    slim(:"home")
end

get('/books') do
    getBooksInfo()
    slim(:"book/index")
end

get('/book/new') do
    if rolllrvel() != nil
        redirect to("/home")
    end
    slim(:"book/new")
end

get('/book/edit') do
    if rolllrvel() <= 1
        redirect to("/home")
    end
    editLinks()
    slim(:"book/edit/index")
end

get('/books/:id/edit') do
    p rolllrvel
    hej(2)
    if rolllrvel > 1
        slim(:"book/edit/edit")
    else
        redirect to("/home")
    end
    
end

get('/place/new') do
    if rolllrvel == nil
        redirect to("/home")
    else 
        slim(:"place/new")
    end
end

get('/pepol/new') do
    if rolllrvel() == nil
        redirect to("/home")
    else 
        slim(:"pepol/new")
    end
end

post('/places') do
    if rolllrvel() != nil
        redirect to("/home")
    end
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

post('/pepol') do
    if rolllrvel() != nil
        redirect to("/home")
    end
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

post('/books') do
    if rolllrvel() != nil
        redirect to("/home")
    end
    title =  params[:title]
    number =  params[:number]
    publiDate = params[:pub_date]
    posionsDrunk = params[:potions]
    piratShipSunk = params[:pirats]
    boar = params[:boar]
    menhirs = params[:stone]
    place = params[:place]
    artist = params[:artist]

    addbooks(title, number, publiDate, posionsDrunk, piratShipSunk, boar, menhirs, artist)
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

    login(username,password)

end
  
post("/users") do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_connfirm]
    register(username,password,password_confirm)
end

get('/rool/update') do
    @listOfreaders = getReaderList()
    slim(:"users/update")
end

get('/rool/:id/update') do
    if rolllrvel() <= 2
        redirect to("/home")
    end
    user_id = params[:id]
    promote(user_id)
end

get('/rool/edit') do
    @listOfreaders = getUserList()
    slim(:"users/update")
end

post('/rool/:id/update') do
    id = params[:id]
    rool = params[:rool]   
    moderate(id,rool)
end

get('/user/edit') do
    slim(:"users/edit")
end

post('/user/:id/delete') do
    user_id = params[:id]
    deletUser(user_id)
    redirect to("/home")
end

post("/book/:id/edit") do
    if rolllrvel() <= 1
        redirect to("/home")
    end
    title =  params[:title]
    number =  params[:number]
    publiDate = params[:pub_date]
    posionsDrunk = params[:potions]
    piratShipSunk = params[:pirats]
    boar = params[:boar]
    menhirs = params[:stone]
    place = params[:place]
    artist = params[:artist]
    id = params[:id]

    editbook(title, number, publiDate, posionsDrunk, piratShipSunk, boar, menhirs, artist, id)
end

get("/book/:id/show") do
    getBooksInfo()
    id = params[:id].to_i
    @booklist.each do |book|
        p"is #{book["id"]} = #{id}"
        p book["id"]
        p id
        if book["id"] == id
            p "in it"
            getBookInfo(id)
        end
    end
    slim(:"book/show") 
end

post("/pepol_in_book/:id/edit") do
    if rolllrvel() <= 1
        redirect to("/home")
    end
    book_id = params[:id]
    pepolAdd = params[:pepolAdd]
    pepolRemove = params[:pepolRemove]
    pepolAdd = pepolAdd.split("\n")
    pepolRemove = pepolRemove.split("\n")

    pepolAdd.map! {|person| person.chomp}
    pepolRemove.map! {|person| person.chomp}

    
    pepolAdd.each do |person|
        addPerson(person,book_id)
    end
    pepolRemove.each do |person|
        removePerson(person,book_id)
    end
    redirect to("/home")
end

post("/book_in_placese/:id/edit") do
    if rolllrvel() <= 1
        redirect to("/home")
    end
    book_id = params[:id]
    placeAdd = params[:placeAdd]
    placeRemove = params[:placeRemove]
    placeAdd = placeAdd.split("\n")
    placeRemove = placeRemove.split("\n")

    placeAdd.map! {|place| place.chomp}
    placeRemove.map! {|place| place.chomp}

    
    placeAdd.each do |place|
        addPlace(place,book_id)
    end
    placeRemove.each do |place|
        removePlace(place,book_id)
    end
    redirect to("/home")
end

get ('/error') do
    slim(:error)
end

