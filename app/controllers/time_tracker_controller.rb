# frozen_string_literal: true

class TimeTrackerController < TrackyController
  def start
    # Early return if timer already running
    return render(:update, layout: false) if @current_timer_session

    @current_timer_session = SessionCreator.new(@current_user, timer_params, params[:commit]).create

    return render_start_page unless @current_timer_session.valid?

    return if issues_invalid

    # Early close the timer session if the timer_end is set and it's valid
    return render_stop_page if @current_timer_session.session_finished? &&
                               @current_timer_session.update(finished: true)

    render :start, layout: false
  end

  def stop
    return render(:stop, layout: false) if @current_timer_session.nil?

    return stop_timer unless params[:cancel]

    @current_timer_session.destroy
    render :cancel, layout: false
  end

  def update
    return render(:start, layout: false) if @current_timer_session.nil?

    return head(:no_content) if @current_timer_session.update(timer_params)

    render :update, layout: false
  end

  private

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

  # Go to start page if timer session is not valid
  def render_start_page
    @current_timer_session.errors.add(:base, :invalid)
    render :start, layout: false
  end

  def render_stop_page
    TimeSplitter.new(@current_timer_session, @current_timer_session.issues).create_time_entries
    flash[:notice] = l(:notice_successful_update)
    render :stop, layout: false
  end

  # Go to update page if connected issues are not valid
  def issues_invalid
    issue_connector = IssueConnector.new(timer_params[:issue_ids] || [], @current_timer_session)

    return if issue_connector.run

    @current_timer_session.errors.add(:issue_id, :invalid)
    render :update, layout: false
  end

  def stop_timer
    if @current_timer_session.update(timer_end: default_end_time_for_timer(@current_timer_session), finished: true)
      TimeSplitter.new(@current_timer_session, @current_timer_session.issues).create_time_entries
      flash[:notice] = l(:notice_successful_update)
      return render :stop, layout: false
    end

    render :update, layout: false
  end
end
