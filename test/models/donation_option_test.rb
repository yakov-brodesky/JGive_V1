require "test_helper"

class DonationOptionTest < ActiveSupport::TestCase
  test "requires label and positive amount" do
    option = DonationOption.new(campaign: campaigns(:one), amount_cents: 0, label: "")

    assert_not option.valid?
    assert_includes option.errors[:amount_cents], "must be greater than 0"
    assert_includes option.errors[:label], "can't be blank"
  end

  test "active ordered scope returns campaign options in position order" do
    options = campaigns(:one).donation_options.active.ordered

    assert_equal [ donation_options(:tree), donation_options(:featured) ], options.to_a
  end
end
