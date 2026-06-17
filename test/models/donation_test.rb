require "test_helper"

class DonationTest < ActiveSupport::TestCase
  test "uses string backed enums" do
    assert_equal "pending", Donation.statuses[:pending]
    assert_equal "one_time", Donation.recurrences[:one_time]
    assert_equal "full_name", Donation.display_preferences[:full_name]
  end

  test "requires donor email" do
    donation = donations(:one)
    donation.donor_email = nil

    assert_not donation.valid?
  end

  test "anonymous donations do not require donor name" do
    donation = donations(:one)
    donation.display_preference = "anonymous"
    donation.donor_name = nil

    assert donation.valid?
  end
end
