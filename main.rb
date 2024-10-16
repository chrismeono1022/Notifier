# frozen_string_literal: true

require_relative 'notifier'

notifier = Notifier.new
notifier.send_daily_report
