# frozen_string_literal: true

class TimerSessionEntryComponent < ViewComponent::Base
  include TimerSessionsHelper

  attr_reader :timer_session_entry, :permission_manager

  def initialize(timer_session_entry:,
                 permission_manager:,
                 discrepancy_detected:,
                 gap_separator: false)
    super
    @timer_session_entry = timer_session_entry
    @permission_manager = permission_manager
    @discrepancy_detected = discrepancy_detected
    @gap_separator = gap_separator
  end

  def display_discrepancy_errors?
    @discrepancy_detected
  end

  def timer_session_entry?
    @timer_session_entry.timer_session?
  end

  def can_destroy_entry?
    permission_manager.can?(:destroy, :timer_sessions)
  end

  def can_edit_entry?
    permission_manager.can?(:edit, :timer_sessions)
  end

  def can_continue_entry?
    permission_manager.can?(:continue, :timer_sessions)
  end

  def row_classes
    classes = []
    classes << 'error-block' if display_discrepancy_errors?
    classes << 'gap-marker' if @gap_separator
    classes.join(' ')
  end
end
