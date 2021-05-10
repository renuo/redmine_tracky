# frozen_string_literal: true

class TimerSessionsController < TrackyController
  before_action :set_current_user
  before_action :set_current_timer_session
  before_action :set_permission_manager

  def index
    @timer_sessions_in_range = TimerSession.includes(:issues, :time_entries)
                                           .finished_sessions.created_by(@current_user)
    set_non_matching_timer_sessions(@timer_sessions_in_range)
    @timer_sessions = apply_filter(@timer_sessions_in_range)
                      .order(timer_start: :desc)
                      .group_by { |entry| entry.timer_start&.to_date }
  end

  def apply_filter(timer_sessions)
    @filter = Filtering::TimerSessionsFilter.new(filter_params)
    @filter.apply(timer_sessions)
  end

  def report
    work_report_query = WorkReportQuery.new(report_query_params)
    result_url = WorkReportQueryBuilder.new(work_report_query).build_query
    redirect_to result_url
  end

  def rebalance
    @timer_session = TimerSession.find(params[:id])
    TimeRebalancer.new(@timer_session.issue_ids,
                       @timer_session).force_rebalance
    redirect_to timer_sessions_path
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

  def time_error
    @timer_session = TimerSession.find(params[:id])
    render :time_error, layout: false
  end

  def update
    @timer_session = TimerSession.find(params[:id])
    if @timer_session.update(timer_session_params)
      TimeRebalancer.new(timer_session_params[:issue_ids],
                         @timer_session).rebalance_entries
      render :update_redirect, layout: false
    else
      render :update, layout: false
    end
  end

  private

  def set_current_user
    @current_user = User.current
  end

  def set_current_timer_session
    @current_timer_session = TimerSession.active_session(@current_user.id).first
  end

  def timer_session_params
    params.require(:timer_session).permit(:comments,
                                          :timer_start,
                                          :timer_end,
                                          issue_ids: [])
  end

  def report_query_params
    params.require(:work_report_query).permit(:date, :period)
  end

  def set_non_matching_timer_sessions(timer_sessions)
    @non_matching_timer_sessions = TimeDiscrepancyLoader.new(
      timer_sessions
    )
                                                        .where_time_not_adding_up
                                                        .pluck(:id).to_h do |timer_session_id|
      [timer_session_id,
       timer_session_id]
    end
  end

  def filter_params
    return {} unless params[:filter].is_a?(ActionController::Parameters)

    params[:filter].permit(:min_date, :max_date).to_h
  end

  def set_permission_manager
    @permission_manager = PermissionManager.new
  end
end
