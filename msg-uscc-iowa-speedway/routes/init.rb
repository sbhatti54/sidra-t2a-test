# encoding: utf-8

# uncomment to enable basic auth
#
# require_relative '../lib/sinatra/basic_auth'
# basic_auth do
#   realm 'USCC RETAIL VOUCHER'
#   username ENV['BASIC_USER']
#   password ENV['BASIC_PW']
# end

require_relative 'home'
require_relative 'autograph'
require_relative 'sweeps'
require_relative 'trivia'