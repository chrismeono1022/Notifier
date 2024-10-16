# frozen_string_literal: true

require_relative './lib/utils'
require_relative 'weather_report'
require_relative 'covid_report'
require 'mail'

class Notifier
  attr_reader :state, :zipcode

  def initialize(state = 'Oregon', zipcode = '97232')
    @state = state
    @zipcode = zipcode
  end

  def send_daily_report
    covid = CovidReport.new(@state)
    covid.create_covid_report

    weather = WeatherReport.new(@zipcode)
    weather.create_weather_report

    email_body = []
    weather.display_data.each_value { |v| email_body << v }
    covid.display_data.each_value { |v| email_body << v }

    email_report(weather.display_data[:date], email_body.join("\n\n"))
  end

  private

  def email_report(date, body)
    mail = Mail.new
    mail.content_type = 'text/plain'
    mail.from = ENV['GMAIL_APP']
    mail.to = ENV['REPORT_RECIPIENT']
    mail.subject = "#{date} - Your covid weather report"
    mail.body = body

    mail.deliver
  end
end
