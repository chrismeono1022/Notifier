# frozen_string_literal: true

require_relative 'utils'

# Helpers to interact with CDC API
module CDC
  STATE_LEVEL_DATA_URL = 'https://www.cdc.gov/wcms/vizdata/NCEZID_DIDRI/NWSSStateMap.json'
  CIRCULATING_VARIANTS_URL = 'https://www.cdc.gov/wcms/vizdata/NCEZID_DIDRI/NWSSVariantBarChart.json'
  COMPARISON_DATA_URL = 'https://www.cdc.gov/wcms/vizdata/NCEZID_DIDRI/NWSSStateLevel.json'
  COMPARISON_DATA_WINDOW = '6 Months'

  # Strip BOM characters before parsing
  def fetch(url)
    url = URI(url)

    res = Net::HTTP.get_response(url)

    JSON.parse(res.body.gsub("\xEF\xBB\xBF", ''), symbolize_names: true)
  end
end
