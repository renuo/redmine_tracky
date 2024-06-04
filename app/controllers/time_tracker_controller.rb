# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
class TimeTrackerController < TrackyController
  def create_or_update
    @current_timer_session = TimerSession.active.find_by(user: User.current)

    return start_timer unless @current_timer_session
    return cancel_timer if params[:cancel].present?

    stop_timer if timer_params[:timer_end].present?
  end

  private

  def start_timer
    @current_timer_session = SessionCreator.new(User.current, timer_params, params[:commit]).create

    unless @current_timer_session.valid?
      @current_timer_session.errors.add(:base, :invalid)
      render :start, layout: false and return
    end

    issue_connector = IssueConnector.new(timer_params[:issue_ids] || [], @current_timer_session)

    unless issue_connector.run
      @current_timer_session.errors.add(:issue_id, :invalid)
      render :update, layout: false and return
    end

    if @current_timer_session.timer_end.present?
      stop_timer
      return
    end

    render :start, layout: false
  end

  def cancel_timer
    @current_timer_session.destroy
    render :cancel, layout: false
  end

  def stop_timer
    if @current_timer_session.update(timer_end: default_end_time_for_timer(@current_timer_session), finished: true)
      TimeSplitter.new(@current_timer_session, @current_timer_session.issues).create_time_entries
      flash[:notice] = l(:notice_successful_update)
      render :stop, layout: false
    else
      render :update, layout: false
    end
  end

  def update_timer
    if @current_timer_session.update(timer_params)
      head :no_content
    else
      render :update, layout: false
    end
  end

  def default_end_time_for_timer(timer_session)
    timer_session&.timer_end.presence || timer_params[:timer_end]&.presence || user_time_zone.now.asctime
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
