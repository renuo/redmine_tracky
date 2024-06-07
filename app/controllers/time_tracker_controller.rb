# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
class TimeTrackerController < TrackyController
  before_action :set_current_timer_session, only: %i[create_or_update cancel]

  def create_or_update
    return start_timer unless @current_timer_session

    cancel_timer if params[:cancel].present?
    stop_timer if timer_params[:timer_end].present?
  end

  def cancel
    if @current_timer_session.blank?
      head :not_found
    else
      cancel_timer
    end
  end

  private

  def set_current_timer_session
    @current_timer_session = TimerSession.active.find_by(user: User.current)
  end

  def cancel_timer
    if @current_timer_session.destroy
      render_js :cancel
    else
      render_js :cancel, :unprocessable_entity
    end
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def start_timer
    @current_timer_session = SessionCreator.new(User.current, timer_params, params[:commit]).create

    unless @current_timer_session.valid?
      @current_timer_session.errors.add(:base, :invalid)
      render_js :start and return
    end

    issue_connector = IssueConnector.new(timer_params[:issue_ids] || [], @current_timer_session)

    unless issue_connector.run
      @current_timer_session.errors.add(:issue_id, :invalid)
      render_js :update and return
    end

    stop_timer and return if @current_timer_session.timer_end.present?

    render_js :start
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  def stop_timer
    if @current_timer_session.update(timer_params.merge(finished: true))
      TimeSplitter.new(@current_timer_session, @current_timer_session.issues).create_time_entries
      flash[:notice] = l(:notice_successful_update)
      render_js :stop
    else
      render_js :update, :unprocessable_entity
    end
  end

  def update_timer
    if @current_timer_session.update(timer_params)
      head :no_content
    else
      render_js :update, :unprocessable_entity
    end
  end

  def default_end_time_for_timer(timer_session)
    timer_session&.timer_end.presence || timer_params[:timer_end]&.presence || user_time_zone.now.asctime
  end

  def render_js(template, status = :ok)
    respond_to do |format|
      format.js { render template, status: }
    end
  end

  def timer_params
    params.require(:timer_session).permit(:comments,
                                          :commit,
                                          :timer_start,
                                          :timer_end,
                                          issue_ids: []).tap do |param|
      param[:issue_ids] ||= []
    end
  end
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
