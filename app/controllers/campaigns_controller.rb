class CampaignsController < ApplicationController
  def index
    @campaigns = Campaign.includes(:organization).order(:id)
  end

  def show
    @campaign = Campaign.includes(:organization, :donation_options).find(params[:id])
    @donation = @campaign.donations.new
    @donation_search = params[:q].to_s.strip
    @donation_sort = params[:sort].presence_in(%w[newest amount]) || "newest"
    @recent_donations = recent_donations
  end

  private

  def recent_donations
    donations = @campaign.donations

    if @donation_search.present?
      donations = donations.where(
        "donor_name ILIKE :query OR donor_email ILIKE :query OR dedication_honoree ILIKE :query OR dedication_recipient_name ILIKE :query OR dedication_recipient_email ILIKE :query OR dedication_message ILIKE :query OR note ILIKE :query",
        query: "%#{@donation_search}%"
      )
    end

    donations = case @donation_sort
    when "amount"
      donations.order(amount_cents: :desc, created_at: :desc)
    else
      donations.order(created_at: :desc)
    end

    donations.limit(12)
  end
end
