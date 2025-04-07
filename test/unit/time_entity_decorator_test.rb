# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class TimeEntityDecoratorTest < ActiveSupport::TestCase
  fixtures :issues, :time_entries

  test '#end_time' do
    session = create(:timer_session, user: User.current, timer_start: Time.zone.now, timer_end: Time.zone.now + 1.hour)
    assert_equal session.timer_end, TimeEntityDecorator.new(session).end_time

    entry = create(:time_entry, user: User.current, spent_on: Time.zone.now, hours: 1)
    assert_equal entry.spent_on + entry.hours.hours, TimeEntityDecorator.new(entry).end_time
  end

  test '#can_overlap_with?' do
    session = create(:timer_session, user: User.current, timer_start: Time.zone.now, timer_end: Time.zone.now + 1.hour)
    entry = create(:time_entry, user: User.current, spent_on: Time.zone.now, hours: 1)

    assert TimeEntityDecorator.new(session).can_overlap_with?(TimeEntityDecorator.new(entry))
    assert TimeEntityDecorator.new(entry).can_overlap_with?(TimeEntityDecorator.new(session))
    assert_not TimeEntityDecorator.new(session).can_overlap_with?(TimeEntityDecorator.new(session))
    assert_not TimeEntityDecorator.new(entry).can_overlap_with?(TimeEntityDecorator.new(entry))
  end

  test '#time_entries_overlap?' do # rubocop:disable Metrics/BlockLength
    session1 = create(:timer_session, user: User.current, timer_start: Time.zone.now,
                                      timer_end: Time.zone.now + 1.hour)
    session2 = create(:timer_session, user: User.current, timer_start: Time.zone.now + 1.hour,
                                      timer_end: Time.zone.now + 2.hours)

    assert_not overlaps_as_decorator?(session1, session2)
    assert_not overlaps_as_decorator?(session2, session1)

    session3 = create(:timer_session, user: User.current, timer_start: Time.zone.now + 30.minutes,
                                      timer_end: Time.zone.now + 1.hours)

    assert overlaps_as_decorator?(session3, session1)
    assert overlaps_as_decorator?(session1, session3)

    base_time = Time.utc(2023, 1, 1, 10, 0, 0)
    session1 = create(:timer_session, user: User.current,
                                      timer_start: base_time,
                                      timer_end: base_time + 1.hour + 25.seconds)
    session2 = create(:timer_session, user: User.current,
                                      timer_start: base_time + 1.hour + 5.seconds,
                                      timer_end: base_time + 2.hours)

    assert_not overlaps_as_decorator?(session1, session2)
    assert_not overlaps_as_decorator?(session2, session1)

    session1 = create(:timer_session, user: User.current,
                                      timer_start: base_time,
                                      timer_end: base_time + 1.hour + 32.seconds)
    session2 = create(:timer_session, user: User.current,
                                      timer_start: base_time + 1.hour,
                                      timer_end: base_time + 2.hours)

    assert overlaps_as_decorator?(session1, session2)
    assert overlaps_as_decorator?(session2, session1)

    session1 = create(:timer_session, user: User.current,
                                      timer_start: base_time,
                                      timer_end: base_time + 1.hour + 32.seconds)
    entry1 = create(:time_entry, user: User.current, spent_on: base_time + 1.hour + 5.seconds)

    assert_not overlaps_as_decorator?(session1, entry1)
    assert_not overlaps_as_decorator?(entry1, session1)

    # session1 = create(:timer_session, user: User.current,
    #                                   timer_start: base_time,
    #                                   timer_end: base_time + 1.hour + 2.minutes)
    # entry1 = create(:time_entry, user: User.current, spent_on: base_time + 1.hour, hours: 0.5)
    #
    # assert overlaps_as_decorator?(session1, entry1)
    # assert overlaps_as_decorator?(entry1, session1)
  end

  def overlaps_as_decorator?(entry, other_entry)
    TimeEntityDecorator.new(entry).overlaps?(TimeEntityDecorator.new(other_entry))
  end
end
