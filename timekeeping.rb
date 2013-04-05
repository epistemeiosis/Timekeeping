#!/usr/bin/env ruby
require 'sinatra'
require 'haml'
require 'sequel'

configure do
  DB = Sequel.sqlite('./db.db')
  begin
    DB.create_table :tasks do
      primary_key :id
      String :name
    end
  rescue Exception
  end
end

get '/' do
  @tasks = DB[:tasks]
  haml File.read('./views/index.html.haml')
end

get '/new' do
  haml File.read('./views/new.html.haml')
end

post '/new' do
  DB[:tasks].insert(:name => params[:name])
  redirect '/'
end

get '/delete/:id' do |id|
  DB[:tasks].delete(id)
  redirect '/'
end
