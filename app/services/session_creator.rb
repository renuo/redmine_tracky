# frozen_string_literal: true

class SessionCreator
  def initialize(user, params)
    @user = user
    @params = params
  end

  def create
    timer_session = TimerSession.create(
      timer_start: timer_start_value,
      comments: @params[:comments],
      user: @user,
      timer_end: @params[:timer_end].presence
    )
    logger.error 'Was not able to create timer session' unless timer_session.persisted? && logger

    timer_session
  end

  private

  def timer_start_value
    (@params[:timer_start].presence || user_time_zone.now.asctime)
  end

  def user_time_zone
    @user.time_zone || Time.zone
  end

  def logger
    ::Rails.logger
  end
end
