require_relative 'lib/utils'

attr :location, :weather_data, :activity_data

class WeatherReport
  def initialize(location)
    @location = location
  end

  def create_weather_report
    @weather_data = fetch_weather_forecast

    @activity_data = fetch_activity_forecast
  end

  private

  def fetch_weather_forecast
    url = "https://dataservice.accuweather.com/forecasts/v1/daily/1day/#{@location}"
    res_body = fetch_api_data(url)

    body = res_body[:DailyForecasts].first

    parse_weather_forecast(body)
  end

  def parse_weather_forecast(body)
    date = DateTime.strptime(body[:Date]).strftime("%a %-m/%-d/%-y")
    headline = body[:Day][:LongPhrase]
    temp_max = body[:Temperature][:Maximum][:Value]
    temp_min = body[:Temperature][:Minimum][:Value]
    pollens = []
    raw_pollens = body[:AirAndPollen].each {
      |i| pollens.push(i.slice(:Name, :Category))
    }

    {
      date: "Today's forecast: #{date}",
      headline: headline,
      high: "High: #{temp_max}",
      low: "Low: #{temp_min}",

      }
  end

  def fetch_activity_forecast
    url = "http://dataservice.accuweather.com/indices/v1/daily/1day/#{@location}"
    res_body = fetch_api_data(url)

    parse_activity_forecast(res_body)
  end

  def parse_activity_forecast(body)
    keys_of_interest = ['Mosquito Activity Forecast', 'Dust & Dander Forecast',
      'Arthritis Pain Forecast', 'Flu Forecast', 'Sinus Headache Forecast',
      'Driving Travel Index', 'Hair Frizz Forecast',
      'Dog Walking Comfort Forecast', 'Makeup and Skincare Forecast']

    formatted_data = {}

    body.each do |i|
      formatted_data[i[:Name]] = i[:Text] if keys_of_interest.include?(i[:Name])
    end

    formatted_data.transform_keys { |k| k.downcase.tr(' ', '_').to_sym}
  end

  def fetch_api_data(endpoint)
    url = URI(endpoint)
    params = { apikey: ENV['ACCUWEATHER_API_KEY'], details: true }

    url.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(url)
    JSON.parse(res.body, symbolize_names: true)
  end

end
