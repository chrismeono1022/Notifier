require_relative 'lib/utils'

class CovidReport

  attr :state, :state_level_data, :circulating_variants, :comparison_data

  def initialize(state)
    @state = state
    @state_level_data = {}
    @circulating_variants = {}
    @comparison_data = []
  end

  def fetch_state_level_data

    data = fetch_cdc_data('https://www.cdc.gov/wcms/vizdata/NCEZID_DIDRI/NWSSStateMap.json')

    @state_level_data = data.select { |i| i[:State] == @state }
  end

  def fetch_circulating_variants
    data = fetch_cdc_data('https://www.cdc.gov/wcms/vizdata/NCEZID_DIDRI/NWSSVariantBarChart.json').last

    @circulating_variants[:date] = Date.parse(data[:week_end]).strftime(
      "%a %m/%d/%y"
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
    data = fetch_cdc_data('https://www.cdc.gov/wcms/vizdata/NCEZID_DIDRI/NWSSStateLevel.json')

    last_two_weeks = data.select { |i| i[:State] == @state }.last(8)

    last_two_weeks.select { |k, v| k[:date_period] == 'All Results'}

    last_two_weeks.select do |k, v|
      if k[:date_period] == 'All Results'
        @comparison_data << OpenStruct.new(
          date: k[:date],
          state_value: k[:state_med_conc].to_f.truncate(2),
          region_value: k[:region_value].to_f.truncate(2),
          national_value: k[:national_value].to_f.truncate(2),
          activity_level: k[:activity_level_label]
        )
      end
    end
  end

  private

  # JSON responses for this API include BOM characters and need to be stripped before parsing
  def fetch_cdc_data(url)
    url = URI(url)

    res = Net::HTTP.get_response(url)

    JSON.parse(res.body.gsub("\xEF\xBB\xBF", ''), symbolize_names: true)
  end
end
