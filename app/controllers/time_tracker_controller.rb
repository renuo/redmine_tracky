# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
class TimeTrackerController < TrackyController
  before_action :set_current_timer_session, only: %i[create update destroy]
  before_action :require_current_timer_session, only: %i[update destroy]

  def create
    head :conflict and return if @current_timer_session.present?

    @current_timer_session = SessionCreator.new(User.current, timer_params, params[:commit]).create

    unless @current_timer_session.valid?
      @current_timer_session.issues << Issue.find(timer_params[:issue_ids]) if timer_params[:issue_ids].present?
      @current_timer_session.errors.add(:base, :invalid)
      render_js :start, :unprocessable_entity and return
    end

    issue_connector = IssueConnector.new(timer_params[:issue_ids] || [], @current_timer_session)
    unless issue_connector.run
      @current_timer_session.errors.add(:issue_id, :invalid)
      render_js :update, :unprocessable_entity and return
    end

    unless @current_timer_session.session_finished?
      render_js :start, :ok and return
    end

    if @current_timer_session.update(timer_params.merge(finished: true))
      TimeSplitter.new(@current_timer_session, @current_timer_session.issues).create_time_entries
      flash[:notice] = l(:notice_successful_update)
      render_js :stop, :ok and return
    end

    render_js :update, :unprocessable_entity
  end

  def update
    if @current_timer_session.update(timer_params)
      if @current_timer_session.session_finished?
        if @current_timer_session.update(finished: true)
          TimeSplitter.new(@current_timer_session, @current_timer_session.issues).create_time_entries
          flash[:notice] = "Successfully stopped timer."
          render_js :stop, :ok
        else 
          render_js :update, :unprocessable_entity
        end
      else
        render_js :update, :ok
      end
    else
      render_js :update, :unprocessable_entity
    end
  end

  def destroy
    if @current_timer_session.destroy
      render_js :cancel
    else
      render_js :cancel, :unprocessable_entity
    end
  end

  private

  def set_current_timer_session
    @current_timer_session = TimerSession.active.find_by(user: User.current)
  end

  def require_current_timer_session
    head :not_found, status: :not_found if @current_timer_session.blank?
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
