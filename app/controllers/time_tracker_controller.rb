# frozen_string_literal: true

class TimeTrackerController < TrackyController
  # rubocop:disable Metrics/AbcSize
  def start
    @timer_offset = offset_for_time_zone
    partial_to_render = :start

    if @current_timer_session.nil?
      @current_timer_session = SessionCreator.new(@current_user, timer_params, params[:commit]).create
      issue_connector = IssueConnector.new(timer_params[:issue_ids] || [], @current_timer_session)

      if issue_connector.run
        partial_to_render = handle_finished_timer_session(@current_timer_session) if @current_timer_session.session_finished?
      else
        @current_timer_session.errors.add(:issue_id, :invalid)
      end
    end

    render partial_to_render, layout: false
  end
  # rubocop:enable Metrics/AbcSize

  def stop
    if @current_timer_session.nil?
      render :stop, layout: false
    elsif params[:cancel].nil?
      handle_stop(@current_timer_session)
    else
      handle_cancel(@current_timer_session)
    end
  end

  def update
    @current_timer_session.update(timer_params)

    if @current_timer_session.valid?
      head :no_content
    else
      render :update, layout: false
    end
  end

  private

  def handle_finished_timer_session(timer_session)
    timer_session.update(finished: true)

    return :start unless timer_session.valid?

    split_time_and_respond_with_success(timer_session)

    :stop
  end

  def handle_cancel(timer_session)
    timer_session.destroy

    render :cancel, layout: false
  end

  def handle_stop(timer_session)
    if timer_session.update(
      timer_end: default_end_time_for_timer(timer_session),
      finished: true
    )
      split_time_and_respond_with_success(timer_session)

      render :stop, layout: false
    else
      render :update, layout: false
    end
  end

  def split_time_and_respond_with_success(timer_session)
    time_splitter = TimeSplitter.new(timer_session, timer_session.issues)
    time_splitter.create_time_entries
    flash[:notice] = l(:notice_successful_update)
  end

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
