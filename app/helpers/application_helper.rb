module ApplicationHelper
  def format_ils(cents)
    number_to_currency(
      (cents.to_i / 100.0),
      unit: "\u20AA",
      precision: 0,
      format: "%u%n"
    )
  end

  def format_progress(campaign)
    "#{[ campaign.progress_percentage, 100 ].min}%"
  end

  def recurrence_options
    {
      "חד פעמי" => "one_time",
      "חודשי" => "monthly"
    }
  end

  def display_preference_options
    {
      "השם שלי וסכום התרומה" => "full_name",
      "שם פרטי וסכום התרומה" => "first_name",
      "סכום התרומה בלבד" => "anonymous"
    }
  end

  def recurrence_label(value)
    recurrence_options.key(value) || value
  end

  def donation_relative_time(donation)
    elapsed = Time.current - donation.created_at

    if elapsed < 1.hour
      "לפני פחות משעה"
    elsif elapsed < 1.day
      "לפני #{(elapsed / 1.hour).floor} שעות"
    elsif elapsed < 2.days
      "אתמול"
    else
      "לפני #{(elapsed / 1.day).floor} ימים"
    end
  end
end
