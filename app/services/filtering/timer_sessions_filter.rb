# frozen_string_literal: true

module Filtering
  class TimerSessionsFilter < BaseFilter
    include Filtering::TimerSessions

    attribute :min_date, :date, default: -> { Time.current.to_date.at_beginning_of_week - 1.week }
    attribute :max_date, :date, default: -> { Time.current.to_date.at_end_of_week }

    private

    def filter_chain
      [
        TimerSessions::ByDate.new(min_date: min_date, max_date: max_date)
      ]
    end
  end
end
