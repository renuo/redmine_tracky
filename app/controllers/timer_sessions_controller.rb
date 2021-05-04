# frozen_string_literal: true

class TimerSessionsController < ApplicationController
  before_action :set_current_user
  before_action :set_current_timer_session

  def index
    create_test_data
    @timer_sessions = TimerSession.includes(:issues).finished_sessions.where(user_id: @current_user)
                                  .order(timer_start: :desc)
                                  .group_by { |entry| entry.timer_start&.to_date }
  end

  # rubocop:disable Metrics/AbcSize
  def create_test_data
    return unless TimerSession.count.zero?

    timer_sessions = [
      TimerSession.create!(
        timer_start: Time.zone.now - 1.hour,
        timer_end: Time.zone.now,
        comments: 'Working on IPA',
        user: @current_user
      ),
      TimerSession.create!(
        timer_start: Time.zone.now - 1.day - 1.hour,
        timer_end: Time.zone.now - 1.day,
        comments: 'Working on LME',
        user: @current_user
      ),
      TimerSession.create!(
        timer_start: Time.zone.now - 1.hour,
        timer_end: Time.zone.now,
        comments: 'Working on Game',
        user: @current_user
      ),
      TimerSession.create!(
        timer_start: Time.zone.now - 1.day - 1.hour,
        timer_end: Time.zone.now - 1.day,
        comments: 'Working on Not Game',
        user: @current_user
      )
    ]

    timer_sessions.each do |timer_session|
      issues = Issue.where(id: [1, 2])
      issues.each do |issue|
        TimerSessionIssue.create!(
          timer_session: timer_session,
          issue: issue
        )
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def set_current_user
    @current_user = User.current
  end

  def set_current_timer_session
    @current_timer_session = TimerSession.active_session(@current_user.id).first
  end
end
