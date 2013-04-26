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
      Time :start_at
      Time :end_at
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
  DB[:tasks].insert(:name => params[:name], :start_at => Time.now)
  redirect '/'
end

get '/end/:id' do |id|
  @task = DB[:tasks].where(:id => id).first
  haml File.read('./views/end.html.haml')
end

post '/end/:id' do |id|
  DB[:tasks].where(:id => id).update(:end_at => Time.now) 
  redirect '/'
end

get '/delete/:id' do |id|
  DB[:tasks].where(:id => id).delete
  redirect '/'
end

get '/update/:id' do |id|
  @task = DB[:tasks].where(:id => id).first
  haml File.read('./views/update.html.haml')
end

post '/update/:id' do |id|
  DB[:tasks].where(:id => id).update(:name => params[:name], :start_at => Time.parse(params[:start_at]), :end_at => Time.parse(params[:end_at]))
  redirect '/'
end


def total(tasks)
  total = tasks.map do |task| 
    if task[:end_at].nil? 
    0
    else
    task[:end_at] - task[:start_at]
    end
  end.reduce(:+)
  "#{(total / 3600).to_i} hours #{((total.to_i % 3600) / 60).to_i} minutes #{(total.to_i % 60)} seconds"
end

