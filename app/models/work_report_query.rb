# frozen_string_literal: true

class WorkReportQuery
  include ActiveModel::Model
  extend ActiveModel::Naming

  AVAILABLE_PERIODS = %i[day week month year].freeze

  attr_accessor :period, :date
end
