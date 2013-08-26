require 'sinatra'
require 'sinatra/flash'
require 'sinatra/reloader'
require 'sinatra/cookies'
require 'mongo_mapper'
require 'json'
require 'chronic'

require_relative 'minify_resources'

class MyApp < Sinatra::Application
  register Sinatra::Reloader
  set :protection, :except => :frame_options
  enable :sessions
  set :session_secret, '03c9fe100fcf579cd70229898381157423345673849e10d0c54121cc37bda6a66ec2a3de3'


  #uncomment to add mongo support
  # configure do
  #   mongouri = ENV['MONGOLAB_URI']
  #mongomapper
  #   uri = URI.parse(mongouri)
  #   MongoMapper.connection = Mongo::Connection.new(uri.host, uri.port)
  #   MongoMapper.database = uri.path.gsub(/^\//, '')
  #   MongoMapper.database.authenticate(uri.user, uri.password)
  #ruby driver
  # $conn = Mongo::MongoClient.from_uri(mongouri, :pool_size => 15)
  # $db = $conn.db(uri.path.gsub(/^\//, ''))
  # end

  configure :production do
    set :clean_trace, true
    set :css_files, :blob
    set :js_files, :blob
    MinifyResources.minify_all
    #ensure stdout logging ("puts") shows up in heroku
    $stdout.sync = true
  end

  configure :development do
    set :css_files, MinifyResources::CSS_FILES
    set :js_files, MinifyResources::JS_FILES
  end

  helpers do
    include Rack::Utils
    include Sinatra::Cookies
    alias_method :h, :escape_html
  end
end

require_relative 'helpers/init'
require_relative 'models/init'
require_relative 'routes/init'
