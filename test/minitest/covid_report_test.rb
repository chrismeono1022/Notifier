require 'pry'
require 'minitest/autorun'

require 'covid_report'

class CovidReportTest < Minitest::Test
  def setup
    @state_level_data = JSON.parse(File.read('test/fixtures/cdc_covid_state_overview_endpoint.json'), symbolize_names: true)
    @detailed_state_data = JSON.parse(File.read('test/fixtures/cdc_covid_state_detailed_endpoint.json'), symbolize_names: true)
    @variant_data = JSON.parse(File.read('test/fixtures/cdc_covid_variant_endpoint.json'), symbolize_names: true)
  end

  def test_create_covid_report_with_stub
    covid = CovidReport.new

    # stub API calls
    api_stubs = ->(uri) {
      if uri == CovidReport::STATE_LEVEL  _DATA_URL
        @state_level_data
      elsif uri == CovidReport::CIRCULATING_VARIANTS_URL
        @variant_data
      elsif uri == CovidReport::COMPARISON_DATA_URL
        @detailed_state_data
      end
    }

    covid.stub :fetch, api_stubs do
      covid.create_covid_report

      assert_equal 'Very High', covid.state_data.label
      assert_equal '10', covid.state_data.level
    end
  end
end
