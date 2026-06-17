class DonationsController < ApplicationController
  def create
    @campaign = Campaign.find(params[:campaign_id])
    @donation = @campaign.donations.new(donation_params)

    # Demo flow: only ever create pending donations, with safe enum defaults.
    @donation.status = "pending"
    @donation.recurrence = "one_time" if @donation.recurrence.blank?
    @donation.display_preference = "full_name" if @donation.display_preference.blank?

    if @donation.save
      redirect_to campaign_path(@campaign), notice: "תודה! התרומה שלך נקלטה וממתינה לאישור."
    else
      @donation_search = ""
      @donation_sort = "newest"
      @recent_donations = @campaign.donations.order(created_at: :desc).limit(8)
      render "campaigns/show", status: :unprocessable_entity
    end
  end

  private

  def donation_params
    permitted = params.require(:donation).permit(
      :donor_email,
      :donor_name,
      :amount,
      :custom_amount,
      :recurrence,
      :display_preference,
      :dedication_message,
      :note,
      :add_note,
      :dedication_enabled,
      :dedication_type,
      :dedication_honoree,
      :dedication_recipient_email
    )

    permitted.delete(:note) unless permitted.delete(:add_note) == "1"
    apply_dedication_fields!(permitted)

    # The form collects whole shekels; persist the value in cents.
    amount = permitted.delete(:custom_amount).presence || permitted.delete(:amount)
    permitted[:amount_cents] = (amount.to_f * 100).round if amount.present?
    permitted
  end

  def apply_dedication_fields!(permitted)
    enabled = permitted.delete(:dedication_enabled) == "1"
    permitted.delete(:dedication_type)
    permitted.delete(:dedication_honoree)
    permitted.delete(:dedication_recipient_email)
    personal_message = permitted.delete(:dedication_message).to_s.strip

    return unless enabled

    prefix = params.dig(:donation, :dedication_type) == "memory" ? "לזכר" : "לכבוד"
    honoree = params.dig(:donation, :dedication_honoree).to_s.strip
    recipient_email = params.dig(:donation, :dedication_recipient_email).to_s.strip
    parts = []
    parts << "#{prefix} #{honoree}" if honoree.present?
    parts << personal_message if personal_message.present?
    parts << "נשלח ל: #{recipient_email}" if recipient_email.present?
    permitted[:dedication_message] = parts.join(" | ") if parts.any?
  end
end
