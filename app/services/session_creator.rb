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
      timer_end: params[:timer_end].presence
    )
    logger.error 'Was not able to create timer session' unless timer_session.persisted? && logger

    timer_session
  end

  private

  def update_with_timer_end?
    @params[:timer_end].present?
  end

  def timer_start_value
    @params[:timer_start].presence || Time.zone.now
  end

  def logger
    ::Rails.logger
  end
end
