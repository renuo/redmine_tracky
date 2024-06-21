# frozen_string_literal: true

class UnfinishedTimerSessionValidator < ActiveModel::Validator
  def validate(record)
    return if record.finished?

    @record = record

    # TODO: add validations
  end
end
