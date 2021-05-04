# frozen_string_literal: true

class TimeTrackerController < ApplicationController
  before_action :set_current_user
  before_action :set_current_timer_session

  # rubocop:disable Metrics/AbcSize
  def start
    if @current_timer_session
      respond_with_error(error: :timer_already_present)
    else
      timer_session = TimerSession.create!(
        timer_start: timer_params[:timer_start].presence || Time.zone.now,
        comments: timer_params[:comments],
        user: @current_user
      )
      TimerSessionIssue.create!(
        timer_session: timer_session,
        issue: Issue.find(1)
      )
      if timer_params[:timer_end]
        create_entry_with_end(timer_session, timer_params[:timer_end])
      else
        @timer_session = timer_session
        render :start, layout: false
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def stop
    if params[:commit].to_sym == :cancel
      handle_cancel
    else
      handle_stop
    end
  end

  private

  def respond_with_error(error: :invalid); end

  def create_entry_with_end(timer_session, timer_end)
    timer_session.update(timer_end: timer_end)
    @timer_session = timer_session
    render :start, layout: true
  end

  def handle_cancel
    @current_timer_session.delete
    render :cancel, layout: false
  end

  def handle_stop
    @current_timer_session.update!(timer_end: Time.zone.now)
    render :stop, layout: false
  end

  def set_current_user
    @current_user = User.current
  end

  def set_current_timer_session
    @current_timer_session = TimerSession.active_session(@current_user.id).first
  end

  def timer_params
    params.require(:timer_session).permit(:issue_ids,
                                          :comments,
                                          :timer_start,
                                          :timer_end)
  end
end
