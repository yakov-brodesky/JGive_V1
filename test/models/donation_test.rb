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

  test "honor dedication requires honoree and recipient email" do
    donation = donations(:one)
    donation.dedication_type = "honor"
    donation.dedication_honoree = nil
    donation.dedication_recipient_email = nil

    assert_not donation.valid?
    assert_includes donation.errors[:dedication_honoree], "can't be blank"
    assert_includes donation.errors[:dedication_recipient_email], "can't be blank"
  end

  test "memory dedication requires recipient name" do
    donation = donations(:two)
    donation.dedication_recipient_name = nil

    assert_not donation.valid?
    assert_includes donation.errors[:dedication_recipient_name], "can't be blank"
  end

  test "honor dedication clears recipient name" do
    donation = donations(:one)
    donation.dedication_recipient_name = "Should be cleared"

    donation.valid?

    assert_nil donation.dedication_recipient_name
  end

  test "dedication summary uses prefix and honoree" do
    donation = donations(:one)

    assert_equal "לכבוד My Honoree", donation.dedication_summary
  end
end
