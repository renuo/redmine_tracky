class SessionCreator
  def initialize(user, params)
    @user = user
    @params = params
  end

  def create
    timer_session = TimerSession.create!(
      timer_start: timer_start_value,
      comments: @params[:comments],
      user: @user,
    )

    if update_with_timer_end?
      timer_session.update(timer_end: @params[:timer_end])
    end

    timer_session
  end

  private
  
  def update_with_timer_end?
    @params[:timer_end].present?
  end

  def timer_start_value
    @params[:timer_start].presence || Time.zone.now
  end

  def validate

  end
end