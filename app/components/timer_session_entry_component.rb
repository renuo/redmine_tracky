# frozen_string_literal: true

class TimerSessionEntryComponent < ViewComponent::Base
  include TimerSessionsHelper

  attr_reader :timer_session_entry, :permission_manager

  def initialize(timer_session_entry:, permission_manager:)
    super
    @timer_session_entry = timer_session_entry
    @permission_manager = permission_manager
  end

  def display_discrepancy_errors?
    @timer_session_entry.discrepancy_detected
  end

  def can_destroy_entry?
    permission_manager.can?(:destroy, :timer_session_entrys)
  end

  def can_edit_entry?
    permission_manager.can?(:edit, :timer_session_entrys)
  end

  def can_continue_entry?
    permission_manager.can?(:continue, :timer_session_entrys)
  end
end
