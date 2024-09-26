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

require 'mail'

mail_opts = {
  address:    'smtp.gmail.com',
  port:       587,
  domain:     'gmail.com',
  user_name:  ENV['GMAIL_APP'],
  password:   ENV['GMAIL_APP_VALUE'],
  authentication: 'plain',
  enable_starttls_auto: true
}

Mail.defaults do
  delivery_method :smtp, mail_opts
end
