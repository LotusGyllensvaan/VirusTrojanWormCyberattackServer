require_relative 'lib/tcp_server'
require_relative 'lib/render'
require_relative 'lib/router'
require 'sqlite3'
#require_relative 'lib/response'

class App < HTTPServer
  r = Router.new

  def self.db
    return @db if @db
    @db = SQLite3::Database.new("DB/database.sqlite")
    @db.results_as_hash = true
    
    return @db
  end

  r.get '/index/:id/:a/:b' do |id, a, b|
    p "added route"
    @id = id
    @a = a.to_i
    @b = b.to_i
  
    
    @product = db.execute('SELECT * FROM equipment WHERE id = ?', id).first
    Render.erb('\test.erb', binding)
  end

  r.post '/restart' do
    redirect '/index/1/2/3'
  end

  run r
end

