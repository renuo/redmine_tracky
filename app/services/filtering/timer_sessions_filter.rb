# frozen_string_literal: true

module Filtering
  class TimerSessionsFilter < BaseFilter
    include Filtering::TimerSessions

    attribute :min_date, :date, default: Time.zone.now - 1.week
    attribute :max_date, :date, default: Time.zone.now.at_end_of_day

    private

    def filter_chain
      [
        TimerSessions::ByDate.new(min_date: min_date, max_date: max_date)
      ]
    end
  end
end
