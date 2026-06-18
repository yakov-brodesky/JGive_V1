require "test_helper"

class DonationsControllerTest < ActionDispatch::IntegrationTest
  test "creates a one-time donation from a donation option" do
    campaign = campaigns(:one)
    option = donation_options(:featured)

    assert_difference -> { campaign.donations.count }, 1 do
      post campaign_donations_path(campaign), params: {
        donation: {
          donor_name: "Test Donor",
          donor_email: "donor@example.com",
          donation_option_id: option.id,
          recurrence: "one_time",
          display_preference: "full_name"
        }
      }
    end

    donation = campaign.donations.order(:created_at).last

    assert_redirected_to campaign_path(campaign)
    assert_equal option.amount_cents, donation.amount_cents
    assert_equal option.id, donation.donation_option_id
    assert donation.one_time?
  end

  test "creates a recurring donation when the campaign allows it" do
    campaign = campaigns(:one)
    option = donation_options(:tree)

    post campaign_donations_path(campaign), params: {
      donation: {
        donor_name: "Monthly Donor",
        donor_email: "monthly@example.com",
        donation_option_id: option.id,
        recurrence: "monthly",
        display_preference: "full_name"
      }
    }

    donation = campaign.donations.order(:created_at).last

    assert_redirected_to campaign_path(campaign)
    assert donation.monthly?
  end

  test "forces one-time when the campaign disallows recurring" do
    campaign = campaigns(:two)

    post campaign_donations_path(campaign), params: {
      donation: {
        donor_name: "Monthly Donor",
        donor_email: "monthly@example.com",
        custom_amount: "100",
        recurrence: "monthly",
        display_preference: "full_name"
      }
    }

    donation = campaign.donations.order(:created_at).last

    assert donation.one_time?
  end

  test "creates a donation from custom amount" do
    campaign = campaigns(:one)

    post campaign_donations_path(campaign), params: {
      donation: {
        donor_name: "Custom Donor",
        donor_email: "custom@example.com",
        custom_amount: "250",
        recurrence: "one_time",
        display_preference: "full_name"
      }
    }

    donation = campaign.donations.order(:created_at).last

    assert_equal 25_000, donation.amount_cents
    assert_nil donation.donation_option_id
  end
end
