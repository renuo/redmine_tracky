require File.expand_path('../test_helper', __dir__)

class DisplayDateFormatBuilderTest < ActiveSupport::TestCase

  test 'format for same date' do
    formatter = DisplayDateFormatBuilder.new(
      Time.zone.local(2001, 2, 3, 4, 5, 6),
      Time.zone.local(2001, 2, 3, 4, 5, 6)
    )
    assert_equal('04:05 - 04:05', formatter.format)
  end

  test 'format for date with same year' do
    formatter = DisplayDateFormatBuilder.new(
      Time.zone.local(2001, 10, 3, 4, 5, 6),
      Time.zone.local(2001, 2, 3, 4, 5, 6)
    )
    assert_equal('03.10 04:05 - 03.02 04:05', formatter.format)
  end

  test 'format with different year' do
    formatter = DisplayDateFormatBuilder.new(
      Time.zone.local(2001, 10, 3, 4, 5, 6),
      Time.zone.local(2002, 10, 3, 4, 5, 6)
    )
    assert_equal('03.10.2001 04:05 - 03.10.2002 04:05', formatter.format)
  end
end
