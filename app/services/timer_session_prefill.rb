# frozen_string_literal: true

# Builds and describes timer sessions that are prefilled from URL query parameters.
#
# Share URL contract (all keys optional, nested under +timer_session+):
#   /timer_sessions?timer_session[issue_ids][]=1&timer_session[issue_ids][]=2
#                  &timer_session[comments]=Pairing
#                  &timer_session[timer_start]=2026-01-05T09:00:00Z
#                  &timer_session[timer_end]=2026-01-05T10:30:00Z
#
# Times are ISO 8601 and transmitted as UTC so that co-workers in different
# time zones see the same instant, rendered in their own time zone.
class TimerSessionPrefill
  MAX_ISSUES = 20
  MAX_COMMENT_LENGTH = 255

  # Query parameters used to share +timer_session_entry+ (a TimerSession or a decorator around it).
  def self.share_params(timer_session_entry)
    {
      issue_ids: timer_session_entry.issues.compact.map(&:id).uniq.first(MAX_ISSUES),
      comments: timer_session_entry.comments.to_s.strip.first(MAX_COMMENT_LENGTH),
      timer_start: timer_session_entry.timer_start&.utc&.iso8601,
      timer_end: timer_session_entry.timer_end&.utc&.iso8601
    }.compact_blank
  end

  def initialize(raw_params, user: User.current)
    @user = user
    @params = if raw_params.is_a?(ActionController::Parameters)
                raw_params.permit(:comments, :timer_start, :timer_end, issue_ids: [])
              else
                ActionController::Parameters.new.permit
              end
  end

  def prefilled?
    issue_ids.any? || comments.present? || timer_start.present? || timer_end.present?
  end

  # An unsaved TimerSession; nothing is persisted until the user submits the form.
  def build
    TimerSession.new(user: @user, comments: comments, timer_start: timer_start, timer_end: timer_end).tap do |session|
      issues.each { |issue| session.issues << issue }
    end
  end

  private

  def issue_ids
    @issue_ids ||= Array.wrap(@params[:issue_ids]).map(&:to_i).select(&:positive?).uniq.first(MAX_ISSUES)
  end

  # Only issues the current user is allowed to see are prefilled.
  def issues
    @issues ||= Issue.visible(@user).where(id: issue_ids).to_a
  end

  def comments
    @comments ||= @params[:comments].to_s.strip.first(MAX_COMMENT_LENGTH)
  end

  def timer_start
    @timer_start ||= parse_time(@params[:timer_start])
  end

  def timer_end
    @timer_end ||= parse_time(@params[:timer_end])
  end

  def parse_time(value)
    return if value.blank?

    Time.zone.parse(value.to_s)
  rescue ArgumentError
    nil
  end
end
