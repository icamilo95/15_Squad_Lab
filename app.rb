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
   @conn.exec("SELECT * FROM squads ORDER BY unique_id DESC") do |result|
      result.each do |squad|
         squads << squad
      end
   end
   @squads = squads
   erb :index
end

#------------ REQUIRE - ADD NEW SQUAD

get '/squads/new' do
   erb :new
end

#------------ CREATE NEW SQUAD

post '/squads' do 
   @conn.exec("INSERT INTO squads (name,mascot) VALUES ($1,$2)",[params[:name],params[:mascot]])
   redirect to '/'
end

#------------ SHOW SQUAD

get '/squads/:squad_id' do
   id = params[:squad_id].to_i
     squad = @conn.exec("SELECT * FROM squads WHERE unique_id=($1)",[id])
     @squad = squad[0]    
   erb :show
end

#------------ EDIT SQUAD

get '/squads/:squad_id/edit' do
   id = params[:squad_id].to_i
     squad = @conn.exec("SELECT * FROM squads WHERE unique_id=($1)",[id])
     @squad = squad[0]    
   erb :edit
end

#------------ UPDATE SQUAD

put '/squads/:squad_id' do
   id = params[:squad_id].to_i
   name = params[:name]
   mascot = params[:mascot]
   
   @conn.exec("UPDATE squads SET name=($1),mascot=($2) WHERE unique_id=($3)",[name,mascot,id])
       
   redirect to '/'
end





























