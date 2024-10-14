require_relative 'lib/utils'

class WeatherReport

  attr :zip_code, :location, :weather_data, :activity_data, :display_data

  def initialize(zip_code)
    @zip_code = zip_code
    @weather_data = {}
    @activity_data = {}
    @display_data = {}
    @location = ''
  end

  def create_weather_report
    lookup_location_key

    fetch_weather_forecast

    fetch_activity_forecast

    format_for_display
  end

  private

  def fetch_weather_forecast
    url = "https://dataservice.accuweather.com/forecasts/v1/daily/1day/#{@location}"
    res_body = fetch_api_data(url, { details: true })

    body = res_body[:DailyForecasts].first

    @weather_data = parse_weather_forecast(body)
  end

  def fetch_activity_forecast
    url = "http://dataservice.accuweather.com/indices/v1/daily/1day/#{@location}"
    res_body = fetch_api_data(url, { details: true })

    @activity_data = parse_activity_forecast(res_body)
  end

  def format_for_display
    @display_data[:date] = "Forecast - #{@weather_data[:date]}"
    @display_data[:headline] = "#{@weather_data[:headline]}."
    @display_data[:temp] = "Today's high is #{@weather_data[:high]}°. The low is #{@weather_data[:low]}°."

    activities = []
    @display_data[:activities] = @activity_data.each { |k, v|
      activities << "#{k.to_s.tr('_', ' ').capitalize}: #{v}"
    }

    @display_data[:activities] = activities.join("\n")
  end

  def lookup_location_key
    url = "http://dataservice.accuweather.com/locations/v1/search?q=#{@zip_code}"

    res_body = fetch_api_data(url, { q: @zip_code })

    @location = res_body.first[:Key]
  end

  def parse_weather_forecast(body)
    date = DateTime.strptime(body[:Date]).strftime("%A %-m/%-d/%-y")
    headline = body[:Day][:LongPhrase]
    temp_max = body[:Temperature][:Maximum][:Value].to_int
    temp_min = body[:Temperature][:Minimum][:Value].to_int
    pollens = []

    body[:AirAndPollen].each {
      |i| pollens.push(i.slice(:Name, :Category))
    }

    {
      date: date.to_s,
      headline: headline,
      high: temp_max.to_s,
      low: temp_min.to_s,

      }
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

    formatted_data.transform_keys { |k| k.downcase.gsub('forecast', '').strip.tr(' ', '_').to_sym }
  end

  def fetch_api_data(endpoint, additional_params = {})
    url = URI(endpoint)
    params = { apikey: ENV['ACCUWEATHER_API_KEY'] }.merge(additional_params)

    url.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(url)

    JSON.parse(res.body, symbolize_names: true)
  end
end
