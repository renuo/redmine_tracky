# frozen_string_literal: true

class TimeTrackerController < TrackyController
  before_action :set_current_timer_session
  accept_api_auth %i[start stop update]

  def start
    start_timer
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
    if timer_params[:absolute_time]
      @current_timer_session.update_with_absolute_time!(timer_params[:absolute_time])
      @current_timer_session.absolute_time = nil
    end

    layout_response(@current_timer_session, :update)
  end

  private

  def start_timer
    @timer_session = SessionCreator.new(@current_user, timer_params, params[:commit]).create
    issue_connector = IssueConnector.new(timer_params[:issue_ids] || [], @timer_session)
    if issue_connector.run
      handle_finished_timer_session and return if @timer_session.session_finished?
    else
      @timer_session.errors.add(:issue_id, :invalid)
    end

    layout_response(@timer_session, :start)
  end

  def handle_finished_timer_session
    @timer_session.update(finished: true)
    if @timer_session.valid?
      split_time_and_respond_with_success(@timer_session)
    else
      layout_response(@current_timer_session, :start)
    end
  end

  def handle_cancel
    @current_timer_session.destroy
    layout_response(@current_timer_session, :cancel)
  end

  def handle_stop
    if @current_timer_session.update(
      timer_end: default_end_time_for_timer(@current_timer_session),
      finished: true
    )
      split_time_and_respond_with_success(@current_timer_session)
    else
      layout_response(@current_timer_session, :update)
    end
  end

  def split_time_and_respond_with_success(timer_session)
    time_splitter = TimeSplitter.new(timer_session)
    time_splitter.create_time_entries

    layout_response(@current_timer_session, :stop)
  end

  def default_end_time_for_timer(current_timer_session)
    (current_timer_session&.timer_end.presence || timer_params[:timer_end]&.presence || user_time_zone.now.asctime)
  end

  def set_current_timer_session
    @current_timer_session = TimerSession.active_session(@current_user.id).first
  end

  def timer_params
    params.require(:timer_session).permit(:comments,
                                          :commit,
                                          :timer_start,
                                          :timer_end,
                                          :absolute_time,
                                          issue_ids: [])
  end
end
