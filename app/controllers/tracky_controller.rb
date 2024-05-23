# frozen_string_literal: true

class TrackyController < ApplicationController
  before_action :set_current_user
  before_action :set_current_timer_session
  before_action :permission_manager
  before_action :verify_permission!
  skip_before_action :verify_authenticity_token

  helper_method :offset_for_time_zone

  def verify_permission!
    return unless User.current
    return if permission_manager.can?(action_name.to_sym, controller_name.to_sym)

    render_403(flash: { error: t('timer_sessions.messages.errors.permission.no_access') })
  end

  def set_current_user
    User.current = User.current
  end

  def set_current_timer_session
    @current_timer_session = TimerSession.active.find_by(user: User.current)
  end

  def user_time_zone
    User.current.time_zone || Time.zone
  end

  def permission_manager
    @permission_manager ||= PermissionManager.new
  end

  private

  def offset_for_time_zone
    return 0 unless User.current&.preference&.time_zone.present?

    Time.zone.now.in_time_zone(User.current.preference.time_zone).utc_offset / 1.minute
  end
end
