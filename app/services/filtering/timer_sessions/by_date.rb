# frozen_string_literal: true

module Filtering
  module TimerSessions
    class ByDate
      def initialize(min_date:, max_date:)
        @min_date = Time.zone.parse(min_date.to_s)
        @max_date = Time.zone.parse(max_date.to_s)
      end

      def apply(transactions)
        transactions.where(timer_start: @min_date&.at_beginning_of_day..@max_date&.at_end_of_day)
      end
    end
  end
end
