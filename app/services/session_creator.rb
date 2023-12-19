# frozen_string_literal: true

class SessionCreator
  def initialize(user, params, commit)
    @user = user
    @params = params
    @commit = commit
  end

  def create
    timer_session = TimerSession.create(
      timer_start: determine_start_of_timer,
      comments: @params[:comments],
      user: @user,
      timer_end: @params[:timer_end].presence
    )
    logger.error 'Was not able to create timer session' unless timer_session.persisted? && logger

    timer_session
  end

  private

  def determine_start_of_timer
    if @commit.try(:to_sym) == :start
      timer_start_value
    else
      start_of_last_session || timer_start_value
    end
  end

  def timer_start_value
    @params[:timer_start].presence || user_time_zone.now.asctime
  end

  def start_of_last_session
    TimerSession.finished.created_by(@user).order(timer_end: :desc)&.first&.timer_end
  end

  def user_time_zone
    @user.time_zone || Time.zone
  end

  def logger
    ::Rails.logger
  end
end
