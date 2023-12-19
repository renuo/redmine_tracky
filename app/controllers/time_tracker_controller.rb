# frozen_string_literal: true

# rubocop:disable Style/IfUnlessModifier, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength
class TimeTrackerController < TrackyController
  def start
    # Early return if timer already running
    if @current_timer_session
      render :update, layout: false and return
    end

    @current_timer_session = SessionCreator.new(@current_user, timer_params, params[:commit]).create

    # Go to start page if timer session is not valid
    unless @current_timer_session.valid?
      @current_timer_session.errors.add(:base, :invalid)
      render :start, layout: false and return
    end

    issue_connector = IssueConnector.new(timer_params[:issue_ids] || [], @current_timer_session)

    # Go to update page if connected issues are not valid
    unless issue_connector.run
      @current_timer_session.errors.add(:issue_id, :invalid)
      render :update, layout: false and return
    end

    # Early close the timer session if the timer_end is set and it's valid
    if @current_timer_session.session_finished? && @current_timer_session.update(finished: true)
      TimeSplitter.new(@current_timer_session, @current_timer_session.issues).create_time_entries
      flash[:notice] = l(:notice_successful_update)
      render :stop, layout: false and return
    end

    # Go back to the start otherwise
    render :start, layout: false
  end

  def stop
    if @current_timer_session.nil?
      render :stop, layout: false and return
    end

    if params[:cancel]
      @current_timer_session.destroy
      render :cancel, layout: false and return
    end

    if @current_timer_session.update(timer_end: default_end_time_for_timer(@current_timer_session), finished: true)
      TimeSplitter.new(@current_timer_session, @current_timer_session.issues).create_time_entries
      flash[:notice] = l(:notice_successful_update)
      render :stop, layout: false
    else
      render :update, layout: false
    end
  end

  def update
    # Start over if timer is not running
    if @current_timer_session.nil?
      render :start, layout: false and return
    end

    if @current_timer_session.update(timer_params)
      head :no_content
    else
      render :update, layout: false
    end
  end

  private

  def default_end_time_for_timer(timer_session)
    (timer_session&.timer_end.presence || timer_params[:timer_end]&.presence || user_time_zone.now.asctime)
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
# rubocop:enable Style/IfUnlessModifier, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength
