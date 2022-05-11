require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require "bcrypt"
require_relative 'model.rb'

enable :sessions

include Model 

before do 
    if rolllrvel(session[:rool]) == nil
        session[:rool] = "reader"
    end
end

# redirect from landingpage to home page and sett rool to reader
#
get('/') do 
    session[:rool] = "reader"
    redirect('/home')
end

# displays home page
#
get('/home') do
    slim(:"home")
end

# Display a list of all books in database
#
# @see Model#getBooksInfo
get('/books') do
    getBooksInfo()
    slim(:"book/index")
end

# Displays a form to add new books to database
#
# @see Model#rolllrvel
get('/book/new') do
    if rolllrvel(session[:rool]) == nil
        redirect to("/home")
    end
    slim(:"book/new")
end

# Displays a list of books wher every book is a link to /books/:id/edit
#
# @see Model#rolllrvel
get('/book/edit') do
    if rolllrvel(session[:rool]) <= 0
        redirect to("/home")
    end
    editLinks()
    slim(:"book/edit/index")
end

# diplays a form wher a books data is editebel
#
#@param [Integer] :id, book id
#
#@see Model#rolllrvel
get('/books/:id/edit') do
    if rolllrvel(session[:rool]) > 1
        slim(:"book/edit/edit")
    else
        redirect to("/home")
    end
    
end

# diplays a form to add place to database 
#
# @see Model#rolllrvel
get('/place/new') do
    if rolllrvel(session[:rool]) == nil
        redirect to("/home")
    else 
        slim(:"place/new")
    end
end

# diplays a form to add pepol to database 
#
# @see Model#rolllrvel
get('/pepol/new') do
    if rolllrvel(session[:rool]) == nil
        redirect to("/home")
    else 
        slim(:"pepol/new")
    end
end

# creatse a new place datavase tabel for places if theo do not already exist and add a relasion betwen te book and the place in a relasiontabel and redirects to /home
#
# @param [Integer] book_num, The number of the book
# @param [Array] places, All the places the user vants to add to the book whit number book_num
#
# @see Model#bookId
# @see Model#addPlace
# @see Model#rolllrvel
post('/places') do
    if rolllrvel(session[:rool]) == nil
        redirect to("/home")
    end
    book_num = params[:book]

    book_id = bookId(book_num)
    places = params[:places]
    places = places.split("\n")
    places.map! {|place| place.chomp}
    places.each do |place|
        if addPlace(place,book_id)
            redirect("/error")
        end
    end
    redirect("/home")
end

# creatse a new person to database tabel for pepol if theo do not already exist and add a relasion betwen te book and the person in a relasiontabel and redirects to /home 
#
# @param [Integer] book_num, The number of the book
# @param [Array] pepol, All the persons the user vants to add to the book whit number book_num
#
# @see Model#bookId
# @see Model#addPerson
# @see Model#rolllrvel
post('/pepol') do
    if rolllrvel(session[:rool]) == nil
        redirect to("/home")
    end
    book_num = params[:book]

    book_id = bookId(book_num)
    pepol = params[:pepol]
    pepol = pepol.split("\n")

    pepol.map! {|person| person.chomp}

    
    pepol.each do |person|
        if addPerson(person,book_id)
            redirect("/error")
        end
    end
    redirect("/home")
end

# creats a new book in te book databse and a new relation betew the book that is added and one of the two artists and redirect to /home
#
# @ param [String] title, the title of the book to add
# @ param [Integer] number, the number of te book to add
# @ param [String] publiDate, the date the book was publiched
# @ param [Integer] posionsDrunk, the amount of posions drunk in the book
# @ param [Integer] piratShipSunk, the amount of pirats ship sunk in the book
# @ param [Integer] boar, the amount of boars wisebel in the book
# @ param [Integer] menhirs, the amount of menhirs wisebel in the book
# @ param [String] artist, the artist of the book
#
# @see Model#addBook
# @see Model#rolllrvel
post('/books') do
    if rolllrvel(session[:rool]) == nil
        redirect to("/home")
    end
    title =  params[:title]
    number =  params[:number]
    publiDate = params[:pub_date]
    posionsDrunk = params[:potions]
    piratShipSunk = params[:pirats]
    boar = params[:boar]
    menhirs = params[:stone]
    artist = params[:artist]

    if addbook(title, number, publiDate, posionsDrunk, piratShipSunk, boar, menhirs, artist)
        redirect("/error")
    end
    redirect("/home")
end

# diplay form to login in a user
#
get("/login") do
    slim(:"users/login")
end

# diplay form to add new user
#
get("/register") do
    slim(:"users/regsister")
end

# destroys session and redirect to /
#
get("/logout") do
    session.destroy
    redirect('/')
end

# vadiodate if user cresidantioal are corect and redirect to /home
#
# @param [Sting] username, the users supsed username
# @param [Sting] password, the users supsed password
#
# @see Model#login
post("/login") do
    username = params[:username]
    password = params[:password]

    tmp = login(username,password)
    if tmp[0]
        redirect("/error")
    end
    session[:id] = tmp[1]
    session[:rool] = tmp[2]
    redirect to("/home")
end
  
#  createe new user
#  
# @param [Sting] username, the users chosen username
# @param [Sting] password, the users chosen password
# @param [Sting] password_confirm, the users chosen passwor again supoedly
#
# @see Model#register
post("/users") do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_connfirm]
    if register(username,password,password_confirm)
        redirect("/error")
    end
    redirect("/home")
end

# Diplays all users white rool reader
# 
# @see Model#getReaderList
# @see Model#rolllrvel
get('/rool/update') do
    if rolllrvel(session[:rool]) < 3
        redirect("/home")
    end
    @listOfreaders = getReaderList()
    slim(:"users/update")
end

# promts a user
#
# @param [Integer] user_id, the id of teh user to promote
#
# @see Model#promote
# @see Model#rolllrvel
get('/rool/:id/update') do
  
   
    if rolllrvel(session[:rool]) <= 1
        redirect to("/home")
    end
    user_id = params[:id]
    promote(user_id)
    redirect("/home")
end

# Displys a list of al users
#
# @see Model#getUserList
get('/rool/edit') do
    @listOfreaders = getUserList()
    slim(:"users/update")
end

# upadest a given users role
# 
# @param [String] rool, new user role
# @param [Integer] id, user id
#
# @see Model#rolllrvel
# @see Model#moderate
post('/rool/:id/update') do
    if rolllrvel() < 3
        redirect("/home")
    end
    id = params[:id]
    rool = params[:rool]   
    moderate(id,rool)
    redirect("/home")
end

# Diplays a list of users and a form to edit ther rool or delete them
#
get('/user/edit') do
    slim(:"users/edit")
end

# Deletas a given user
#  
# @param [Integer] user_id, the users id
# 
# @see Model#deletUser
# @see Model#rolllrvel
post('/user/:id/delete') do
    if rolllrvel(session[:rool]) != 4
        redirect to("/home")
    end
    user_id = params[:id]
    deletUser(user_id)
    redirect to("/home")
end

# update data for a given book
#
# @param [String] title, the title of the book to add
# @param [Integer] number, the number of te book to add
# @param [String] publiDate, the date the book was publiched
# @param [Integer] posionsDrunk, the amount of posions drunk in the book
# @param [Integer] piratShipSunk, the amount of pirats ship sunk in the book
# @param [Integer] boar, the amount of boars wisebel in the book
# @param [Integer] menhirs, the amount of menhirs wisebel in the book
# @param [String] artist, the artist of the book
# @param [Integer] id, the book id
#
# @see Model#editbook
# @see Model#rolllrvel
post("/book/:id/edit") do
    if rolllrvel(session[:rool]) <= 1
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

    if editbook(title, number, publiDate, posionsDrunk, piratShipSunk, boar, menhirs, artist, id)
        redirect("/error")
    end
    redirect("/home")
end

# Diplays info from given book
#
# @param [Integer] id, book id
#
# @see Model#getBooksInfo
# @see Model#rolllrvel
get("/book/:id/show") do
    getBooksInfo()
    id = params[:id].to_i
    @booklist.each do |book|

        if book["id"] == id
            p "in it"
            getBookInfo(id)
        end
    end
    slim(:"book/show") 
end

# Updatse pepol, and pepol booka realsion tabels in database 
#
# @param [Integer] book_id, book id
# @param [Array] pepolAdd, All persons to add
# @param [Array] pepolRemove, All persons to remove
#
# @see Model#removePerson
# @see Model#addPlace
# @see Model#rolllrvel
post("/pepol_in_book/:id/edit") do
    if rolllrvel(session[:rool]) <= 1
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
        if addPerson(person,book_id)
            redirect("/home")
        end
    end
    pepolRemove.each do |person|
        removePerson(person,book_id)
    end
    redirect to("/home")
end

# Updatse places, and place book realsions tabels in database 
#
# @param [Integer] book_id, book id
# @param [Array] placeAdd, All places to add
# @param [Array] placeRemove, All places to remove
#
# @see Model#addPlace
# @see Model#removePlace
# @see Model#rolllrvel
post("/book_in_placese/:id/edit") do
    if rolllrvel(session[:rool]) <= 1
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
        if addPlace(place,book_id)
            redirect("/error")
        end
    end
    placeRemove.each do |place|
        removePlace(place,book_id)
    end
    redirect to("/home")
end

# Diplays a generick error measage
#
get ('/error') do
    slim(:error)
end

