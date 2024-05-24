# frozen_string_literal: true

class TrackyController < ApplicationController
  before_action :verify_permission!
  skip_before_action :verify_authenticity_token

  helper_method :offset_for_time_zone

  def verify_permission!
    return unless User.current
    return if User.current.allowed_to_globally?(action: action_name.to_sym, controller: controller_name.to_s)

    render_403(flash: { error: t('timer_sessions.messages.errors.permission.no_access') })
  end

  def user_time_zone
    User.current.time_zone || Time.zone
  end

  private

  def offset_for_time_zone
    return 0 unless User.current&.preference&.time_zone.present?

    Time.zone.now.in_time_zone(User.current.preference.time_zone).utc_offset / 1.minute
  end
end
