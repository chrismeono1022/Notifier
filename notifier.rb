require_relative'./lib/utils'
require_relative 'weather_report'
require_relative 'covid_report'

class Notifier

  # extract daily report class from here
  def create_daily_report
    weather = WeatherReport.new('40924_PC')

    weather.create_weather_report

    covid = CovidReport.new('Oregon')

    covid.create_covid_report
  end

  def send_daily_report

  end
end
