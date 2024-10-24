# frozen_string_literal: true

require_relative 'utils'

# Helpers to interact with AccuWeather API
module AccuWeather
  LOCATION_KEY_URL = 'http://dataservice.accuweather.com/locations/v1/search?q='
  DAILY_WEATHER_URL = 'https://dataservice.accuweather.com/forecasts/v1/daily/1day/'
  DAILY_ACTIVITIES_URL = 'http://dataservice.accuweather.com/indices/v1/daily/1day/'
  KEYS_OF_INTEREST = [
    'Mosquito Activity Forecast', 'Dust & Dander Forecast',
    'Arthritis Pain Forecast', 'Flu Forecast', 'Sinus Headache Forecast',
    'Driving Travel Index', 'Hair Frizz Forecast',
    'Dog Walking Comfort Forecast', 'Makeup and Skincare Forecast'
  ].freeze

  def fetch(endpoint, params = {})
    url = URI(endpoint)

    params = { apikey: ENV['ACCUWEATHER_API_KEY'] }.merge(params)

    url.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(url)

    JSON.parse(res.body, symbolize_names: true)
  end
end
