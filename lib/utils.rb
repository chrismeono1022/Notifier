require 'dotenv'
Dotenv.load('keys.env')
require 'dotenv/load'

if ENV['NOTIFIER'] == 'development'
  require 'pry'
end

require 'uri'
require 'net/http'
require 'JSON'
require 'Date'
