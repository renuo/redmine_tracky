# frozen_string_literal: true

class TrackyController < ApplicationController
  before_action :set_current_user
  before_action :permission_manager
  before_action :verify_permission!
  skip_before_action :verify_authenticity_token

  private

  def verify_permission!
    return unless User.current
    return if permission_manager.can?(action_name.to_sym, controller_name.to_sym)

    render_403(flash: { error: t('timer_sessions.messages.errors.permission.no_access') })
  end

  def set_current_user
    @current_user = User.current
  end

  def user_time_zone
    @current_user.time_zone || Time.zone
  end

  def permission_manager
    @permission_manager ||= PermissionManager.new
  end

  def formatted_api_response(model, code)
    {
      model: model.to_json,
      valid: model.valid?,
      errors: model.errors,
      status_code: code
    }.to_json
  end

  def layout_response(timer_session, partial)
    yield if block_given?
    respond_to do |format|
      format.api do
        render json: formatted_api_response(
          timer_session,
          200
        )
      end

      format.js do
        render partial, layout: false
      end

      format.html
    end
  end

  def redirect_response(timer_session, path)
    yield if block_given?
    respond_to do |format|
      format.api do
        render json: formatted_api_response(
          timer_session,
          200
        )
      end

      format.js

      format.html do
        redirect_to path
      end
    end
  end
end
