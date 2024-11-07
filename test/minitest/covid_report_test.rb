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

    @covid_report.stub :fetch, @api_stubs do
      @covid_report.create_covid_report
    end
  end

  def test_creates_covid_report
    refute_nil @covid_report.report
  end

  def test_fetches_state_data
    assert_equal 'Oregon', @covid_report.state_data.name

    assert_equal 'Very High', @covid_report.state_data.label

    assert_equal '10', @covid_report.state_data.level
  end

  def test_fetches_circulating_variants
    assert_equal 7, @covid_report.circulating_variants.count
  end

  def test_fetches_comparison_data
    fixture_last_week = StateDetailed.new(
      name: 'Oregon',
      date: Date.parse('2024-08-24'),
      level: '10',
      label: 'Very High',
      state_level: 18.13,
      national_level: 8.33,
      region_level: 9.71
    )
    fixture_current_week = StateDetailed.new(
      name: 'Oregon',
      date: Date.parse('2024-08-31'),
      level: '10',
      label: 'Very High',
      state_level: 11.95,
      national_level: 7.78,
      region_level: 9.16
    )

    report_last_week = @covid_report.state_overview_data[-2]
    report_current_week = @covid_report.state_overview_data[-1]

    assert_equal fixture_last_week.name, report_last_week.name
    assert_equal fixture_last_week.date, report_last_week.date
    assert_equal fixture_last_week.level, report_last_week.level
    assert_equal fixture_last_week.label, report_last_week.label

    assert_equal fixture_current_week.name, report_current_week.name
    assert_equal fixture_current_week.date, report_current_week.date
    assert_equal fixture_current_week.level, report_current_week.level
    assert_equal fixture_current_week.label, report_current_week.label
  end
end
