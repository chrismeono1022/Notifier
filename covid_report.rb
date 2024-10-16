require_relative 'lib/utils'

class CovidReport
  STATE_LEVEL_DATA_URL = 'https://www.cdc.gov/wcms/vizdata/NCEZID_DIDRI/NWSSStateMap.json'
  CIRCULATING_VARIANTS_URL = 'https://www.cdc.gov/wcms/vizdata/NCEZID_DIDRI/NWSSVariantBarChart.json'
  COMPARISON_DATA_URL = 'https://www.cdc.gov/wcms/vizdata/NCEZID_DIDRI/NWSSStateLevel.json'

  attr_reader :state, :state_level_data, :circulating_variants, :comparison_data, :display_data

  def initialize(state)
    @state = state
    @state_level_data = {}
    @circulating_variants = {}
    @comparison_data = {}
    @display_data = {}
  end

  def create_covid_report
    fetch_state_level_data
    fetch_circulating_variants
    fetch_comparison_data
    format_for_display
  end

  private

  def fetch_state_level_data
    data = fetch_cdc_data(STATE_LEVEL_DATA_URL)

    @state_level_data = data.select { |i| i[:State] == @state }.first.transform_keys(&:downcase)
  end

  def fetch_circulating_variants
    data = fetch_cdc_data(CIRCULATING_VARIANTS_URL).last

    @circulating_variants[:date] = Date.parse(data[:week_end]).strftime(
      "%A %m/%d/%y"
    )

    variants = []

    data.select do |k,v|
      if !v.nil? && k != :week_end
        variants << OpenStruct.new(name: k, value: v.to_f)
      end
    end

    @circulating_variants[:variants] = variants.sort_by { |i| i.value }
  end

  def fetch_comparison_data
    data = fetch_cdc_data(COMPARISON_DATA_URL)

    most_recent_data = []

    data.select { |k|
      k[:State] == @state && k[:date_period] == '6 Months'
    }.each do | k |
      most_recent_data << OpenStruct.new(
        date: Date.parse(k[:date]).strftime("%A %m/%d/%y"),
        state_value: k[:state_med_conc].to_f.truncate(2),
        region_value: k[:region_value].to_f.truncate(2),
        national_value: k[:national_value].to_f.truncate(2),
        activity_level: k[:activity_level_label]
      )
    end

    most_recent_data.sort_by! { |k| k.date }

    @comparison_data = { last_week: most_recent_data[-2], current_week: most_recent_data[-1] }
  end

  def format_for_display
    @display_data[:overview] = "The covid activity level in #{state_level_data[:state]} is #{state_level_data[:activity_level]} - #{state_level_data[:activity_level_label]}."

    comparison = ['This is how the numbers are trending: ']
    comparison << "#{comparison_data[:current_week].date} - Covid activity: #{comparison_data[:current_week].activity_level} - #{@state}: #{comparison_data[:current_week].state_value} - Region: #{comparison_data[:current_week].region_value} - National: #{comparison_data[:current_week].national_value}"

    comparison << "#{comparison_data[:last_week].date} - Covid activity: #{comparison_data[:last_week].activity_level} - #{@state}: #{comparison_data[:last_week].state_value} - Region: #{comparison_data[:last_week].region_value} - National: #{comparison_data[:last_week].national_value}"

    @display_data[:comparison] = comparison.join("\n")

    variants = ['The most recent variants']
    circulating_variants[:variants].last(3).each { |i| variants << " - variant #{i.name}: #{i.value}%" }

    @display_data[:variants] = variants.join('')
  end

  # Strip BOM characters before parsing
  def fetch_cdc_data(url)
    url = URI(url)

    res = Net::HTTP.get_response(url)

    JSON.parse(res.body.gsub("\xEF\xBB\xBF", ''), symbolize_names: true)
  end
end
