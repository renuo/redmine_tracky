# frozen_string_literal: true

class WorkReportQuery
  include ActiveModel::Model
  extend ActiveModel::Naming

  attr_accessor :period, :date
end
