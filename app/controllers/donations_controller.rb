class DonationsController < ApplicationController
  def create
    @campaign = Campaign.includes(:organization, :donation_options).find(params[:campaign_id])
    @donation = @campaign.donations.new(donation_params)

    # Demo flow: only ever create pending donations, with safe enum defaults.
    @donation.status = "pending"
    @donation.recurrence = "one_time" if @donation.recurrence.blank?
    # Recurring billing is not implemented; only offer it when the campaign opts in.
    @donation.recurrence = "one_time" unless @campaign.allows_recurring?
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
      :donation_option_id,
      :custom_amount,
      :recurrence,
      :display_preference,
      :dedication_message,
      :note,
      :add_note,
      :dedication_enabled,
      :dedication_type,
      :dedication_honoree,
      :dedication_recipient_name,
      :dedication_recipient_email
    )

    permitted.delete(:note) unless permitted.delete(:add_note) == "1"
    apply_dedication_fields!(permitted)
    resolve_amount!(permitted)
    permitted
  end

  def resolve_amount!(permitted)
    custom_amount = permitted.delete(:custom_amount)
    option_id = permitted.delete(:donation_option_id)

    if custom_amount.present?
      permitted[:amount_cents] = (custom_amount.to_f * 100).round
      permitted[:donation_option_id] = nil
      return
    end

    return if option_id.blank?

    option = @campaign.donation_options.find_by(id: option_id)
    return unless option

    permitted[:amount_cents] = option.amount_cents
    permitted[:donation_option_id] = option.id
  end

  def apply_dedication_fields!(permitted)
    enabled = permitted.delete(:dedication_enabled) == "1"

    unless enabled
      permitted[:dedication_type] = nil
      permitted[:dedication_honoree] = nil
      permitted[:dedication_recipient_name] = nil
      permitted[:dedication_recipient_email] = nil
      permitted[:dedication_message] = nil
      return
    end

    permitted[:dedication_recipient_name] = nil if permitted[:dedication_type] != "memory"
  end
end
