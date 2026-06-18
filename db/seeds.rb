venatata = Organization.find_or_initialize_by(registration_number: "580689537")
venatata.update!(
  name: "ונטעת",
  category: "סביבה ובעלי חיים",
  city: "תל אביב",
  email: "info@venatata.org",
  phone: "0528622966",
  website: "http://www.venatata.org"
)

orange_garden = venatata.campaigns.find_or_initialize_by(title: "הגן הכתום")
orange_garden.update!(
  organization: venatata,
  subtitle: "לזכר בני משפחת ביבס וילדי ה-7 באוקטובר",
  cover_image_url: "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=1600&q=80",
  goal_amount_cents: 200_000_000,
  baseline_raised_amount_cents: 103_815_800,
  baseline_donor_count: 3_383,
  currency: "ILS",
  allows_recurring: false,
  story: <<~STORY
    הצטרפו עכשיו והיו ממקימי ׳הגן הכתום׳ לזכר שירי, אריאל וכפיר ביבס, ולזכר כל ילדי ה-7 באוקטובר.

    אחרי תקופה ארוכה של כאב והתמודדות, המיזם מבקש ליצור מקום של חיים, ריפוי ותקווה. על פני 20 דונם יוקם מרחב חי של טבע, מים, משחק, משפחה וזיכרון - פתוח לכולם.

    בגן הכתום יוקם מרחב חדשני שישלב בין טבע, משחק, ריפוי וזיכרון: מתחם גינון טיפולי-קהילתי, בוסתני פרי, נחל אקולוגי, מרחב זיכרון לילדי השבעה באוקטובר, מתקני משחק, קיר משאלות ומרחבי פיקניק משפחתיים.

    כל תרומה תומכת ישירות בהקמת הגן: כל עץ, כל שביל וכל פינה שתוקם יקרו בזכות השותפים לקמפיין.
  STORY
)

orange_garden.donations.destroy_all
orange_garden.donation_options.destroy_all

orange_garden_options = [
  { amount_cents: 18_000, label: "נטיעת עץ", position: 0 },
  { amount_cents: 26_000, label: "נטיעת 2 עצים", position: 1 },
  { amount_cents: 36_000, label: "נטיעת 3 עצים - לזכרם", position: 2, badge: "הכי נבחר" },
  { amount_cents: 180_000, label: "בונים מרחב לילדים", position: 3 },
  { amount_cents: 500_000, label: "בוני הגן הכתום", position: 4 }
].each_with_object({}) do |attributes, options|
  option = orange_garden.donation_options.create!(attributes)
  options[option.amount_cents] = option
end

orange_garden.donations.create!([
  {
    donor_name: "Yael Cohen",
    donor_email: "yael@example.com",
    amount_cents: 18_000,
    donation_option: orange_garden_options.fetch(18_000),
    recurrence: "one_time",
    display_preference: "first_name",
    dedication_type: "memory",
    dedication_honoree: "ילדי ישראל",
    dedication_recipient_name: "משפחת כהן",
    dedication_recipient_email: "yael@example.com",
    dedication_message: "לזכרם ולמען ילדי ישראל",
    status: "paid"
  },
  {
    donor_name: "David Levi",
    donor_email: "david@example.com",
    amount_cents: 36_000,
    donation_option: orange_garden_options.fetch(36_000),
    recurrence: "monthly",
    display_preference: "full_name",
    dedication_type: "honor",
    dedication_honoree: "משפחת לוי",
    dedication_recipient_email: "david@example.com",
    dedication_message: "בתקווה לימים טובים",
    status: "pending"
  },
  {
    donor_email: "anonymous@example.com",
    amount_cents: 5_000,
    recurrence: "one_time",
    display_preference: "anonymous",
    note: "Donation seeded for the demo campaign",
    status: "paid"
  }
])

latet = Organization.find_or_initialize_by(registration_number: "580328003")
latet.update!(
  name: "לתת",
  category: "רווחה וסיוע הומניטרי",
  city: "תל אביב",
  email: "info@latet.org.il",
  phone: "03-6833388",
  website: "https://www.latet.org.il"
)

holiday_meals = latet.campaigns.find_or_initialize_by(title: "ארוחות חמות למשפחות")
holiday_meals.update!(
  organization: latet,
  subtitle: "עוזרים למשפחות לקבל ארוחה חמה ובטוחה",
  cover_image_url: "https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?auto=format&fit=crop&w=1600&q=80",
  goal_amount_cents: 50_000_000,
  baseline_raised_amount_cents: 12_450_000,
  baseline_donor_count: 742,
  currency: "ILS",
  allows_recurring: false,
  story: <<~STORY
    אלפי משפחות בישראל מתמודדות עם חוסר ביטחון תזונתי מדי יום.

    התרומה שלכם מסייעת ברכישת מצרכי מזון, אריזת סלי סיוע והעברת ארוחות חמות למשפחות שזקוקות לכך עכשיו.
  STORY
)

holiday_meals.donations.destroy_all
holiday_meals.donation_options.destroy_all

holiday_meals_options = [
  { amount_cents: 7_200, label: "ארוחה חמה", position: 0 },
  { amount_cents: 12_000, label: "סל מזון משפחתי", position: 1, badge: "מומלץ" },
  { amount_cents: 18_000, label: "סיוע שבועי למשפחה", position: 2 },
  { amount_cents: 36_000, label: "סיוע חודשי למשפחה", position: 3 }
].each_with_object({}) do |attributes, options|
  option = holiday_meals.donation_options.create!(attributes)
  options[option.amount_cents] = option
end

holiday_meals.donations.create!([
  {
    donor_name: "Maya Avraham",
    donor_email: "maya@example.com",
    amount_cents: 12_000,
    donation_option: holiday_meals_options.fetch(12_000),
    recurrence: "one_time",
    display_preference: "full_name",
    dedication_type: "honor",
    dedication_honoree: "משפחות בישראל",
    dedication_recipient_email: "maya@example.com",
    dedication_message: "בשביל עוד משפחה סביב שולחן",
    status: "paid"
  },
  {
    donor_email: "hidden@example.com",
    amount_cents: 7_200,
    donation_option: holiday_meals_options.fetch(7_200),
    recurrence: "one_time",
    display_preference: "anonymous",
    status: "pending"
  }
])
