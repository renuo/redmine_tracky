require File.expand_path('../test_helper', __dir__)

class DisplayDateFormatBuilderTest < ActiveSupport::TestCase

  test 'format_for_same_date' do
    formatter = DisplayDateFormatBuilder.new(
      Time.zone.local(2001, 2, 3, 4, 5, 6),
      Time.zone.local(2001, 2, 3, 4, 5, 6)
    )
    assert_equal('04:05 - 04:05', formatter.format)
  end

  test 'format_for_date_with_same_year' do
    formatter = DisplayDateFormatBuilder.new(
      Time.zone.local(2001, 10, 3, 4, 5, 6),
      Time.zone.local(2001, 2, 3, 4, 5, 6)
    )
    assert_equal('03.10 04:05 - 03.02 04:05', formatter.format)
  end

  test 'format_with_different_year' do
    formatter = DisplayDateFormatBuilder.new(
      Time.zone.local(2001, 10, 3, 4, 5, 6),
      Time.zone.local(2002, 10, 3, 4, 5, 6)
    )
    assert_equal('03.10.2001 04:05 - 03.10.2002 04:05', formatter.format)
  end
end
