# frozen_string_literal: true

class PermissionManager
  def can?(action, controller)
    allowed_to?(action, controller)
  end

  def cannot?(action, controller)
    !allowed_to?(action, controller)
  end

  def forbidden_to_access_operation
    I18n.t('timer_sessions.permissions.not_allowed')
  end

  private

  def allowed_to?(action, controller)
    action_arguments = {
      controller: controller.to_s,
      action: action
    }
    user.allowed_to_globally?(action_arguments)
  end

  def user
    @user ||= User.current
  end
end
