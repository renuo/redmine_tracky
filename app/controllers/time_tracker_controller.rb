# frozen_string_literal: true

class TimeTrackerController < ApplicationController
  before_action :set_current_user
  before_action :set_current_timer_session

  def start
    if @current_timer_session
      respond_with_error(error: :timer_already_present)
    else
      timer_session = SessionCreator.new(@current_user, timer_params).create
      issue_connector = IssueConnector.new(timer_params[:issue_ids] || [], timer_session)
      issue_connector.run
      if timer_session.session_finished?
        time_splitter = TimeSplitter.new(timer_session)
        time_splitter.create_time_entries
        timer_session.update(finished: true)
        render :stop, layout: true
      else
        @timer_session = timer_session
        render :start, layout: false
      end
    end
  end

  def stop
    if params[:cancel].nil?
      handle_stop
    else
      handle_cancel
    end
  end

  def update
    @current_timer_session.update(timer_params)
    render :update, layout: false
  end

  private

  def respond_with_error(error: :invalid); end

  def handle_cancel
    @current_timer_session.delete
    render :cancel, layout: false
  end

  def handle_stop
    if @current_timer_session.update(
      timer_end: @current_timer_session.timer_end.presence || Time.zone.now,
      finished: true
    )
      render :stop, layout: false
      else
      render :update, layout: false
    end
  end

  def set_current_user
    @current_user = User.current
  end

  def set_current_timer_session
    @current_timer_session = TimerSession.active_session(@current_user.id).first
  end

  def timer_params
    params.require(:timer_session).permit(:comments,
                                          :timer_start,
                                          :timer_end,
                                          issue_ids: [])
  end
end
