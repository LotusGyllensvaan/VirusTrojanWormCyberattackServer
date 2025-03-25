require_relative 'lib/tcp_server'
require_relative 'lib/render'
require_relative 'lib/router'
require_relative 'lib/response'
require 'sqlite3'

class App < HTTPServer
  def initialize
    super 4567

    def self.db
      return @db if @db
      @db = SQLite3::Database.new("DB/database.sqlite")
      @db.results_as_hash = true
      
      return @db
    end
  
    get '/index/:id/:a/:b' do |id, a, b|
      @id = id
      @a = a.to_i
      @b = b.to_i
    
      @products = db.execute('SELECT * FROM equipment')
      @product = db.execute('SELECT * FROM equipment WHERE id = ?', id).first
      Render.erb('\test.erb', binding)
    end

    get '/newsite' do |id, a, b|
      Render.erb('\hello.erb', binding)
    end

    post '/restart' do
      params
      redirect '/index/1/2/3'
    end

    post '/add' do
      input_values = [params['article'], params['description'], params['category']]
      db.execute('INSERT INTO equipment (article, description, category) VALUES(?, ?, ?)', input_values)
      redirect '/index/1/2/3'
    end
  end
end

app = App.new
app.start
