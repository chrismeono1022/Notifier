# frozen_string_literal: true

require 'pry'
require 'minitest/autorun'
require 'covid_report'

class CovidReportTest < Minitest::Test
  def setup
    @state_level_data = JSON.parse(File.read('test/fixtures/cdc_covid_state_overview_endpoint.json'),
                                   symbolize_names: true)
    @detailed_state_data = JSON.parse(File.read('test/fixtures/cdc_covid_state_detailed_endpoint.json'),
                                      symbolize_names: true)
    @variant_data = JSON.parse(File.read('test/fixtures/cdc_covid_variant_endpoint.json'), symbolize_names: true)

    @covid_report = CovidReport.new

    @api_stubs = lambda { |uri|
      case uri
      when CovidReport::STATE_LEVEL_DATA_URL
        @state_level_data
      when CovidReport::CIRCULATING_VARIANTS_URL
        @variant_data
      when CovidReport::COMPARISON_DATA_URL
        @detailed_state_data
      end
    }
  end

  def test_creates_covid_report
    @covid_report.stub :fetch, @api_stubs do
      @covid_report.create_covid_report

      refute_nil @covid_report.report
    end
  end
end
