require "test_helper"

class CampaignTest < ActiveSupport::TestCase
  test "belongs to an organization" do
    assert_equal organizations(:one), campaigns(:one).organization
  end

  test "progress includes baseline and donations that count toward progress" do
    campaign = campaigns(:one)

    assert_equal 1_001, campaign.raised_amount_cents
    assert_equal 2, campaign.total_donor_count
  end
end
