# frozen_string_literal: true

class TimerSessionEntryComponent < ViewComponent::Base
  include TimerSessionsHelper

  attr_reader :timer_session_entry

  def initialize(timer_session_entry:,
                 discrepancy_detected:,
                 overlap_detected: false,
                 gap_separator: false)
    super
    @timer_session_entry = timer_session_entry
    @discrepancy_detected = discrepancy_detected
    @overlap_detected = overlap_detected
    @gap_separator = gap_separator
  end

  def display_discrepancy_errors?
    @discrepancy_detected
  end

  def display_overlap_errors?
    @overlap_detected
  end

  def timer_session_entry?
    @timer_session_entry.timer_session?
  end

  def can_destroy_entry?
    User.current.allowed_to_globally?(action: :destroy, controller: 'timer_sessions')
  end

  def can_edit_entry?
    User.current.allowed_to_globally?(action: :edit, controller: 'timer_sessions')
  end

  def can_continue_entry?
    User.current.allowed_to_globally?(action: :continue, controller: 'timer_sessions')
  end

  def share_url
    datetime_format = I18n.t('timer_sessions.formats.datetime_format')
    params = {
      issue_ids: @timer_session_entry.issues.map(&:id),
      comments: @timer_session_entry.comments,
      timer_start: @timer_session_entry.timer_start&.strftime(datetime_format),
      timer_end: @timer_session_entry.timer_end&.strftime(datetime_format)
    }.compact_blank
    timer_sessions_path(params)
  end

  def row_classes
    classes = []
    classes << 'error-block' if display_discrepancy_errors?
    classes << 'error-block-overlap' if display_overlap_errors?
    classes << 'gap-marker' if @gap_separator
    classes.join(' ')
  end
end
