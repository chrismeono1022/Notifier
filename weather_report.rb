# frozen_string_literal: true

require_relative 'lib/utils'
require_relative 'lib/accuweather'
require_relative 'models/weather_models'

# Create weather report, uses AccuWeather API via Accuweather module
class WeatherReport
  include AccuWeather

  attr_reader :zip_code, :location_key, :weather_forecast, :activities_forecast, :report

  def initialize(zipcode)
    @zip_code = zipcode
    @location_key = ''
    @weather_forecast = {}
    @activities_forecast = []
  end

  def create_weather_report
    lookup_location_key

    fetch_weather_forecast

    fetch_activities_forecast

    format_for_display
  end

  private

  def lookup_location_key
    url = "#{LOCATION_KEY_URL}#{zip_code}"

    res = fetch(url, { q: zip_code })

    @location_key = res.first[:Key]
  end

  def fetch_weather_forecast
    url = "#{DAILY_WEATHER_URL}#{location_key}"

    res = fetch(url, { details: true })

    body = res[:DailyForecasts].first

    parse_weather_forecast(body)
  end

  def parse_weather_forecast(body)
    daily_pollens = []

    body[:AirAndPollen].each do |pollen|
      daily_pollens.push(Pollen.new(name: pollen[:Name], level: pollen[:Category]))
    end

    @weather_forecast = WeatherForecast.new(
      date: DateTime.strptime(body[:Date]),
      headline: body[:Day][:LongPhrase],
      max: body[:Temperature][:Maximum][:Value],
      min: body[:Temperature][:Minimum][:Value],
      pollens: daily_pollens
    )
  end

  def fetch_activities_forecast
    url = "#{DAILY_ACTIVITIES_URL}#{location_key}"

    res_body = fetch(url, { details: true })

    parse_activities_forecast(res_body)
  end

  def parse_activities_forecast(body)
    body.each do |activity|
      next unless KEYS_OF_INTEREST.include?(activity[:Name])

      @activities_forecast.push(Activity.new(
                                  name: activity[:Name],
                                  value: activity[:Category],
                                  headline: activity[:Text]
                                ))
    end
  end

  def format_for_display
    formatted_data = []

    formatted_data << "Forecast for #{weather_forecast.date} - #{weather_forecast.headline}."
    formatted_data << "Today's high is #{weather_forecast.max}. Today's low is #{weather_forecast.min}.\n"

    formatted_data << "Today's pollens are: "
    weather_forecast.pollens.each do |pollen|
      formatted_data << "#{pollen.name}: #{pollen.level}"
    end

    formatted_data << "\n"

    activities_forecast.each do |activity|
      formatted_data << "#{activity.name}: #{activity.headline}"
    end

    @report = formatted_data.join("\n")
  end
end
