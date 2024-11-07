# frozen_string_literal: true

require 'pry'
require 'minitest/autorun'
require 'weather_report'

class WeatherReportTest < Minitest::Test
  def setup
    @location_lookup_data = JSON.parse(File.read('test/fixtures/accuweather_location_key_lookup_endpoint.json'),
                                       symbolize_names: true)
    @daily_weather_data = JSON.parse(File.read('test/fixtures/accuweather_weather_endpoint.json'),
                                     symbolize_names: true)
    @daily_activity_data = JSON.parse(File.read('test/fixtures/accuweather_activities_endpoint.json'),
                                      symbolize_names: true)

    @weather_report = WeatherReport.new('97232')

    @api_stubs = lambda { |uri, _|
      case uri
      when "#{WeatherReport::LOCATION_KEY_URL}#{@weather_report.zip_code}"
        @location_lookup_data
      when "#{WeatherReport::DAILY_WEATHER_URL}#{@weather_report.location_key}"
        @daily_weather_data
      when "#{WeatherReport::DAILY_ACTIVITIES_URL}#{@weather_report.location_key}"
        @daily_activity_data
      end
    }

    @weather_report.stub :fetch, @api_stubs do
      @weather_report.create_weather_report
    end
  end

  def test_creates_weather_report
    refute_nil @weather_report.report
  end

  def test_fetches_appropriate_location_key
    assert_equal '40924_PC', @weather_report.location_key
  end

  def test_fetches_daily_weather_and_pollens_forecast
    refute_nil @weather_report.weather_forecast.date

    refute_nil @weather_report.weather_forecast.headline

    refute_nil @weather_report.weather_forecast.max

    refute_nil @weather_report.weather_forecast.min

    assert_equal %w[AirQuality Grass Mold Ragweed Tree UVIndex].sort,
                 @weather_report.weather_forecast.pollens.map(&:name).sort
  end

  def test_fetches_daily_activities_forecast
    assert_equal 9, @weather_report.activities_forecast.count

    assert_equal WeatherReport::KEYS_OF_INTEREST.sort,
                 @weather_report.activities_forecast.map(&:name).sort
  end

  def test_report_provides_only_one_arthritis_index
    activities = @weather_report.activities_forecast.select do |activitiy|
      activitiy.name == 'Arthritis Pain Forecast'
    end

    assert_equal 1, activities.count
  end
end
