# frozen_string_literal: true

class TimeTrackerController < TrackyController
  before_action :set_current_user
  before_action :set_current_timer_session
  before_action :set_permission_manager

  def start
    if @current_timer_session
      # TODO: invalid
    else
      start_timer
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

  def start_timer
    @timer_session = SessionCreator.new(@current_user, timer_params).create
    issue_connector = IssueConnector.new(timer_params[:issue_ids] || [], @timer_session)
    if issue_connector.run
      if @timer_session.session_finished?
        handle_finished_timer_session
      else
        render :start, layout: false
      end
    else
      @timer_session.errors.add(:issue_id, :invalid)
      render :start, layout: false
    end
  end

  def handle_finished_timer_session
    @timer_session.update(finished: true)
    if @timer_session.valid?
      time_splitter = TimeSplitter.new(@timer_session)
      time_splitter.create_time_entries
      render :stop, layout: false
    else
      render :start, layout: false
    end
  end

  def handle_cancel
    @current_timer_session.delete
    render :cancel, layout: false
  end

  def handle_stop
    if @current_timer_session.update(
      timer_end: @current_timer_session&.timer_end.presence || timer_params[:timer_end] || Time.zone.now,
      finished: true
    )
      time_splitter = TimeSplitter.new(@current_timer_session)
      time_splitter.create_time_entries
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

  def set_permission_manager
    @permission_manager = PermissionManager.new
  end
end
