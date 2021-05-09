# frozen_string_literal: true

class DisplayDateFormatBuilder
  TIME_FORMAT = I18n.t('timer_sessions.formats.time')
  DATE_FORMAT_WITH_YEAR = I18n.t('timer_sessions.formats.date_with_year')
  DATE_FORMAT_WITHOUT_YEAR = I18n.t('timer_sessions.formats.date_without_year')

  def initialize(start_datetime, end_datetime)
    @start_datetime = start_datetime
    @end_datetime = end_datetime
  end

  def format
    formatted_values.join(' - ')
  end

  private

  def formatted_values
    return same_date_format if @start_datetime.to_date == @end_datetime.to_date

    if @start_datetime.to_date.year == @end_datetime.to_date.year
      same_year_format
    else
      out_of_range_format
    end
  end

  def same_date_format
    [@start_datetime, @end_datetime].map { |datetime| datetime.strftime(TIME_FORMAT) }
  end

  def same_year_format
    [@start_datetime, @end_datetime]
      .map { |datetime| datetime.strftime([DATE_FORMAT_WITHOUT_YEAR, TIME_FORMAT].join(' ')) }
  end

  def out_of_range_format
    [@start_datetime, @end_datetime]
      .map do |datetime|
      datetime.strftime([DATE_FORMAT_WITH_YEAR,
                         TIME_FORMAT].join(' '))
    end
  end
end
