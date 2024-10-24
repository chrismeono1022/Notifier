# frozen_string_literal: true

require_relative '../lib/utils'

# represents daily weather forecast from AccuWeather, used as a single obj
class WeatherForecast
  attr_reader :date, :headline, :max, :min, :pollens

  def initialize(date: Date.today, headline: '', max: 0, min: 0, pollens: [])
    @date = date.strftime('%A %m/%d/%y')
    @headline = headline
    @max = max.round(2)
    @min = min.round(2)
    @pollens = pollens
  end
end

# represents pollen from daily weather forecast, usually part of collection
class Pollen
  attr_reader :name, :level

  def initialize(name: '', level: '')
    @name = name
    @level = level
  end
end

# represents activity forecast, usually part of a collection
class Activity
  attr_reader :name, :value, :headline

  def initialize(name: '', value: '', headline: '')
    @name = name
    @value = value
    @headline = headline
  end
end
