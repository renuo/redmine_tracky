# frozen_string_literal: true

class TimerSessionsController < ApplicationController
  before_action :set_current_user
  before_action :set_current_timer_session

  def index
    @timer_sessions = TimerSession.includes(:issues).finished_sessions.where(user_id: @current_user)
                                  .order(timer_start: :desc)
                                  .group_by { |entry| entry.timer_start&.to_date }
  end

  def destroy
    timer_session = TimerSession.find(params[:id])
    TimerEntityCleaner.new(timer_session).run
    timer_session.destroy
    redirect_to timer_sessions_path
  end

  def edit
    @timer_session = TimerSession.find(params[:id])
    render :edit, layout: false
  end

  def update; end

  private

  def set_current_user
    @current_user = User.current
  end

  def set_current_timer_session
    @current_timer_session = TimerSession.active_session(@current_user.id).first
  end
end
