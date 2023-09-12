# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class IssueSearcherTest < ActiveSupport::TestCase
  fixtures :users, :issues

  setup do
    User.current = User.find(2)
    @service = IssueSearcher.new
  end

  test 'call - search by id' do

  end

  test 'call - orders results by id' do

  end

  test 'call - filters closed issues' do

  end
end
