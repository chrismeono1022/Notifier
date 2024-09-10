# To do: consolidate requirements into main

require 'net/http'
require 'uri'
require 'open-uri'
require 'csv'
require 'pry'
require 'JSON'
require 'Date'

# JSON responses for this CDC API include BOM characters and will be stripped before parsing
class Covid

  attr :high_level_data, :prominent_variant, :comparison_data

  def fetch_high_level_data
    url = URI('https://www.cdc.gov/wcms/vizdata/NCEZID_DIDRI/NWSSStateMap.json')

    res = Net::HTTP.get_response(url)

    @high_level_data = JSON.parse(res.body.gsub("\xEF\xBB\xBF", ''), symbolize_names: true)
  end

  def fetch_prominent_variant
    url = URI('https://www.cdc.gov/wcms/vizdata/NCEZID_DIDRI/NWSSVariantBarChart.json')

    res = Net::HTTP.get_response(url)

    @prominent_variant = JSON.parse(res.body.gsub("\xEF\xBB\xBF", ''), symbolize_names: true).last
  end

  # wip: slow endpoint, lots of data, filter out the noise
  def fetch_comparison_data
    url = URI('https://www.cdc.gov/wcms/vizdata/NCEZID_DIDRI/NWSSStateLevel.json')

    res = Net::HTTP.get_response(url)

    @comparison_data = JSON.parse(res.body.gsub("\xEF\xBB\xBF", ''), symbolize_names: true)
  end

end
