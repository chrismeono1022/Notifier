require_relative 'lib/utils'

class CovidVariant
  attr_reader :name, :value, :date

  def initialize(name: '', value: 0, date: Date.today)
    @name = name
    @value = value.to_f.round(2)
    @date = date.strftime('%A %m/%d/%y')
  end
end

class StateOverview
  attr_reader :name, :level, :label

  def initialize(name: '', level: '', label: '')
    @name = name
    @level = level
    @label = label
  end
end

class StateDetailed
  attr_reader :name, :level, :label, :date, :state_level, :national_level, :region_level

  def initialize(name: '', level: '', label: '', date: Date.today, state_level: 0,
    national_level: 0, region_level: 0)
    @name = name
    @level = level
    @label = label
    @date = date.strftime('%A %m/%d/%y')
    @state_level = state_level.to_f.round(2)
    @national_level = national_level.to_f.round(2)
    @region_level = region_level.to_f.round(2)
  end
end
