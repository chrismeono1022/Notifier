# frozen_string_literal: true

require_relative 'lib/utils'
require_relative 'lib/cdc'
require_relative 'models/covid_models'

# Create a covid report, uses CDC API via CDC module
class CovidReport
  include CDC

  attr_reader :state, :state_data, :circulating_variants, :state_overview_data,
              :report

  def initialize(state = 'Oregon')
    @state = state
    @state_level_data = {}
    @circulating_variants = []
    @state_overview_data = {}
    @comparison_data = []
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
    data = fetch(STATE_LEVEL_DATA_URL)

    selected_state = data.select { |result| result[:State] == state }.first
                         .transform_keys(&:downcase)

    @state_data = StateOverview.new(
      name: selected_state[:state],
      level: selected_state[:activity_level],
      label: selected_state[:activity_level_label]
    )
  end

  def fetch_circulating_variants
    data = fetch(CIRCULATING_VARIANTS_URL).last

    date = Date.parse(data[:week_end])

    variants = []

    data.each do |key, value|
      next if value.nil?
      next if key == :week_end

      variants << CovidVariant.new(
        name: key,
        value: value,
        date: date
      )
    end

    @circulating_variants = variants.sort_by(&:value).reverse
  end

  def fetch_comparison_data
    data = fetch(COMPARISON_DATA_URL)

    comparison_data = data.select do |result|
      result[:State] == state && result[:date_period] == COMPARISON_DATA_WINDOW
    end

    data_of_interest = []

    comparison_data.each do |data|
      data_of_interest << StateDetailed.new(
        name: data[:State],
        level: data[:activity_level],
        label: data[:activity_level_label],
        date: Date.parse(data[:date]),
        state_level: data[:state_med_conc],
        national_level: data[:national_value],
        region_level: data[:region_value]
      )
    end

    @state_overview_data = data_of_interest.sort_by(&:date)
  end

  def format_for_display
    formatted_data = []

    formatted_data << "The covid activity level in #{state_data.name} is #{state_data.level} - #{state_data.label}."

    last_week = state_overview_data[-2]
    current_week = state_overview_data[-1]

    formatted_data << 'This is how the numbers are trending:'
    formatted_data << "#{current_week.date} - Covid Activity"
    formatted_data << "#{current_week.name}: #{current_week.state_level}"
    formatted_data << "Region: #{current_week.region_level}"
    formatted_data << "Nation: #{current_week.national_level}\n"

    formatted_data << "#{last_week.date} - Covid Activity"
    formatted_data << "#{last_week.name}: #{last_week.state_level}"
    formatted_data << "Region: #{last_week.region_level}"
    formatted_data << "Nation: #{last_week.national_level}\n"

    formatted_data << 'The most recent variants:'

    circulating_variants.last(3).each { |variant| formatted_data << "#{variant.name}: #{variant.value}%" }

    @report = formatted_data.join("\n")
  end
end
