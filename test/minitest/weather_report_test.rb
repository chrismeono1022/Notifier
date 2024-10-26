require 'pry'
require 'minitest/autorun'
require 'weather_report'

class WeatherReportTest < Minitest::Test
  def setup
    @location_lookup_data = JSON.parse(File.read('test/fixtures/accuweather_location_key_lookup_endpoint.json'), symbolize_names: true)
    @daily_weather_data = JSON.parse(File.read('test/fixtures/accuweather_weather_endpoint.json'), symbolize_names: true)
    @daily_activity_data = JSON.parse(File.read('test/fixtures/accuweather_activities_endpoint.json'), symbolize_names: true)

    @weather_report = WeatherReport.new('97232')

    @api_stubs = ->(uri, _) {
      if uri == "#{WeatherReport::LOCATION_KEY_URL}#{@weather_report.zip_code}"
        @location_lookup_data
      elsif uri == "#{WeatherReport::DAILY_WEATHER_URL}#{@weather_report.location_key}"
        @daily_weather_data
      elsif uri == "#{WeatherReport::DAILY_ACTIVITIES_URL}#{@weather_report.location_key}"
        @daily_activity_data
      end
    }
  end

  def test_creates_weather_report
    @weather_report.stub :fetch, @api_stubs do
      @weather_report.create_weather_report

      refute_nil @weather_report.report
    end
  end

  def test_report_provides_only_one_arthritis_index
    @weather_report.stub :fetch, @api_stubs do
      @weather_report.create_weather_report

      activities = @weather_report.activities_forecast.select { |activitiy|
        activitiy.name == 'Arthritis Pain Forecast'
      }

      assert_equal 1, activities.count
    end
  end
end
