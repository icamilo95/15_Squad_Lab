require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'better_errors'
require 'pg'


configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = __dir__
end


set :conn, PG.connect(dbname: 'squadlab') 

before do                              
   @conn = settings.conn
end

#------------ REDIDECTS TO SQUADS / DOES NOTHING
get '/' do
   redirect '/squads'
end

#------------ REDIDECTS TO LIST OF SQUADS 

get '/squads' do
   squads = []
   @conn.exec("SELECT * FROM squads ORDER BY id_sq ASC") do |result|
      result.each do |squad|
         squads << squad
      end
   end
   @squads = squads
   erb :index
end

#------------ REQUIRE - ADD NEW SQUAD - REDIRECTS TO NEW 

get '/squads/new' do
   erb :new
end

#------------ REQUIRE - ADD NEW STUDENT - REDIRECTS TO NEWSTUDENT

get '/squads/:id/newstudent' do
   id = params[:id].to_i
   @id = id
   erb :newstudent

end

#------------ CREATE NEW SQUAD

post '/squads' do 
   @conn.exec("INSERT INTO squads (name_sq,mascot) VALUES ($1,$2)",[params[:name],params[:mascot]])
   redirect to '/'
end


#------------ CREATE NEW STUNDENT

post '/squads/:id/students' do 
   id = params[:id]
   
   @conn.exec("INSERT INTO students (name_stu,age,spirit_animal,is_leader,squad_id) VALUES ($1,$2,$3,$4,$5)",[params[:name],params[:age].to_i,params[:animal], params[:leader],id.to_i])

redirect to '/squads/'<< id << '/students'
end

#------------ SHOW INFO FROM SQUAD

get '/squads/:id_sq' do
   id = params[:id_sq].to_i
     squad = @conn.exec("SELECT * FROM squads WHERE id_sq=($1)",[id])
     @squad = squad[0]    
     erb :show
end

#------------ EDIT SQUAD

get '/squads/:id_sq/edit' do
   id = params[:id_sq].to_i
     squad = @conn.exec("SELECT * FROM squads WHERE id_sq=($1)",[id])
     @squad = squad[0]    
   erb :edit
end

#------------ UPDATE SQUAD

put '/squads/:id_sq' do
   id = params[:id_sq].to_i
   name = params[:name]
   mascot = params[:mascot]
   @conn.exec("UPDATE squads SET name_sq=($1),mascot=($2) WHERE id_sq=($3)",[name,mascot,id])
   redirect to '/'
end

#------------ SHOW STUDENTS FROM INDIVIDUAL SQUAD

get '/squads/:id_sq/students' do
   id = params[:id_sq].to_i        
   number_students = @conn.exec("SELECT COUNT (name_stu) FROM students WHERE squad_id=$1",[id])
   if number_students[0]["count"].to_i == 0
     @id_sq = id 
     erb :message_new_stu
   else
      squad = @conn.exec("SELECT * FROM squads JOIN students ON squads.id_sq = students.squad_id WHERE id_sq=($1) ORDER BY id_stu ASC",[id])
      @squad = squad
      erb :studentlist
   end
end

#------------ SHOW STUDENTS INFO

get '/squads/:id_sq/students/:id_stu' do
   id_stu = params[:id_stu].to_i
   student = @conn.exec("SELECT * FROM students WHERE id_stu=($1)",[id_stu])
   @student = student[0]    
   erb :show_student
end

#------------ EDIT STUDENT

get '/squads/:id_sq/students/:id_stu/edit' do
   id = params[:id_stu].to_i
     student = @conn.exec("SELECT * FROM students WHERE id_stu=($1)",[id])
     @student = student[0]  
  
   erb :edit_student
end

#------------ UPDATE STUDENT

put '/squads/:id_sq/students' do
   id = params[:id_sq].to_i
   name = params[:name]
   age = params[:age]
   animal = params[:animal]
   squad_id = params[:squad_id]
   leader = params[:leader]
  
   @conn.exec("UPDATE students SET name_stu=($1),age=($2),spirit_animal=($3),squad_id=($4),is_leader=($5) WHERE id_stu=($6) ",[name,age,animal,squad_id,leader,id])  
   redirect to '/squads/' << squad_id << '/students'
    
end

#------------ DELETE SQUAD

delete '/squads/:id_sq' do
   id = params[:id_sq].to_i
   number_studentes = @conn.exec("SELECT COUNT (name_stu) FROM students WHERE squad_id=$1",[id])
   if number_studentes[0]["count"].to_i == 0
      @conn.exec("DELETE FROM squads WHERE id_sq=($1)",[id])
      redirect to '/'   
   else
      "This Squad still contains students. It can't be deleted"
   end
end

#------------ DELETE STUDENT

delete '/squads/:squad_id/students/:id_stu' do
   id = params[:id_stu].to_i
   squad_id = params[:squad_id]
   @conn.exec("DELETE FROM students WHERE id_stu=($1)",[id])
   redirect to '/squads/' << squad_id << '/students'

end

















