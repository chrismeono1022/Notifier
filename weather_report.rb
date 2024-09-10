# To do: consolidate requirements into main
require 'dotenv'
Dotenv.load('keys.env')
require 'uri'
require 'net/http'
require 'pry'
require 'JSON'
require 'Date'
require 'dotenv/load'
# require './formatter'

class Notifier
  def fetch_api_data(endpoint)
    # wrap in rescue clause
    url = URI(endpoint)
    params = { apikey: ENV['ACCUWEATHER_API_KEY'], details: true }

    url.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(url)
    JSON.parse(res.body, symbolize_names: true)
  end

  def parse_weather_forecast(body)
    date = DateTime.strptime(body[:Date]).strftime("%a %-m/%-d/%-y")
    headline = body[:Day][:LongPhrase]
    temp_max = body[:Temperature][:Maximum][:Value]
    temp_min = body[:Temperature][:Minimum][:Value]
    pollens = []
    raw_pollens = body[:AirAndPollen].each { |i| pollens.push(i.slice(:Name, :Category))}

    {
      date: "Today's forecast: #{date}",
      headline: headline,
      high: "High: #{temp_max}",
      low: "Low: #{temp_min}",

      }
  end

  def parse_activity_forecast(body)
    keys_of_interest = ['Mosquito Activity Forecast', 'Dust & Dander Forecast', 'Arthritis Pain Forecast', 'Flu Forecast', 'Sinus Headache Forecast', 'Driving Travel Index', 'Hair Frizz Forecast', 'Dog Walking Comfort Forecast', 'Makeup and Skincare Forecast']

    formatted_data = {}

    body.each do |i|
      formatted_data[i[:Name]] = i[:Text] if keys_of_interest.include?(i[:Name])
    end

    formatted_data.transform_keys { |k| k.downcase.tr(' ', '_').to_sym}
  end

  def fetch_activity_forecast
    url = 'http://dataservice.accuweather.com/indices/v1/daily/1day/40924_PC'
    res_body = fetch_api_data(url)

    parse_activity_forecast(res_body)
  end

  # 45.5296, -122.6463 lat, long
  def fetch_weather_forecast
    url = 'https://dataservice.accuweather.com/forecasts/v1/daily/1day/40924_PC'
    res_body = fetch_api_data(url)
    body = res_body[:DailyForecasts].first

    parse_weather_forecast(body)
  end

  def fetch_data
    weather_hash = fetch_weather_forecast

    activity_hash = fetch_activity_forecast


    puts weather_hash

    puts activity_hash
  end
end


t = Notifier.new
t.fetch_data
