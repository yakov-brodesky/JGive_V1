# JGive

A small server-rendered Rails demo of a donation campaign platform (no React, GraphQL, or payment checkout).

## Overview

- Organizations run campaigns; campaigns collect donations.
- Pages are server-rendered ERB views (Hotwire/Turbo defaults), styled with plain CSS.
- The donation form creates a `pending` donation and redirects back to the campaign page with a success message.

## Setup

- Ruby: see `.ruby-version`.
- Database: PostgreSQL via Docker (`docker compose up`). Development database is `jgive_development`.
- Install dependencies and prepare the database:

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed   # creates 2 organizations, 2 campaigns, 5 donations
bin/rails server
```

## Running tests

```bash
bin/rails test
```

## Campaign progress (important caveat)

Campaign progress (raised amount and donor count) is computed as:

```
baseline_raised_amount_cents + donations.counts_toward_progress.sum(:amount_cents)
baseline_donor_count          + donations.counts_toward_progress.count
```

In this demo, `Donation.counts_toward_progress` includes both `pending` and `paid`
donations, so newly submitted (pending) donations immediately affect campaign totals.
This keeps the demo flow simple since there is no real payment checkout.

In a real payment system, only `paid`/settled donations should count toward
campaign totals. A pending donation that is never paid should not inflate progress.

## Donation amounts and recurring donations

### Preset amounts are database-driven

Each campaign defines its own preset donation tiers via the `donation_options`
table (`belongs_to :campaign`), instead of hardcoding amounts in a helper. A
donation can reference the chosen option (`donations.donation_option_id`) or use
a free-form custom amount. Seed two campaigns' tiers in [`db/seeds.rb`](db/seeds.rb).

### Recurring donations (intentionally cut scope)

The form offers one-time vs. recurring (הוראת קבע). A campaign opts in via the
`campaigns.allows_recurring` boolean; when `false`, the recurring option is
rendered disabled ("בקרוב") and the controller defensively forces `one_time`.
Currently `recurrence` is just a stored donor preference on the `Donation` — no
billing schedule is generated, because **payment/checkout is out of scope** for
this assignment.

To actually run recurring billing, I would add:

- A `donation_schedules` (or `subscriptions`) table: `donation_id`, `interval`
  (`monthly`), `installments` (e.g. 12/36), `next_charge_on`, `status`
  (`active`/`paused`/`cancelled`), and the payment-provider subscription/token id.
- A `donation_charges` (installment ledger) table: one row per attempted charge
  with `scheduled_on`, `amount_cents`, `status` (`scheduled`/`paid`/`failed`),
  `paid_at`, and the provider charge/transaction id.
- A scheduled job (Solid Queue) that finds due charges, calls the provider, and
  updates the ledger; a webhook moves each charge `pending → paid` (and the parent
  donation), mirroring the one-time flow below.

Until then, recurring progress would count the single stored amount, not a
projected pledge total, to avoid inflating campaign totals with uncharged future
installments.

### Stripe integration (how I would wire real payments)

This demo stops at a `pending` donation. In production I would use **Stripe Connect**
so JGive (the platform) can collect donations on behalf of many charities, each with
its own **Connected Account**.

#### Stripe objects involved

| Stripe object | Role in JGive |
|---------------|---------------|
| **Connected Account** (`acct_…`) | One per `Organization`. The charity onboarded via Stripe Connect; funds settle to them. |
| **Checkout Session** | Hosted payment page Stripe renders. Created server-side after the donor submits the form; donor is redirected to `session.url`. |
| **PaymentIntent** | Underlying one-time charge. A Checkout Session in `mode: "payment"` creates one automatically. |
| **Subscription** | For הוראת קבע (recurring). Checkout Session in `mode: "subscription"` creates one. |
| **Webhook events** | Async source of truth (`checkout.session.completed`, `invoice.paid`, etc.). Never mark a donation `paid` from the redirect alone. |

The object you create at checkout time is a **Checkout Session** (`Stripe::Checkout::Session.create`).

#### Connect model

```
Donor → JGive (platform account)
         └─ Connected Account (Organization / charity)
```

- Each `Organization` would store `stripe_account_id` (and onboarding status).
- New charities onboard via a **Connect Account Link** (`account_links.create`) — Stripe-hosted KYC/bank setup.
- Donations route to the campaign's organization connected account using either:
  - **Destination charges** — charge on the platform, transfer to `destination: org.stripe_account_id` (common for marketplaces), or
  - **Direct charges** — charge on the connected account (`stripe_account` header); the charity is merchant of record.

JGive can take a platform fee via `application_fee_amount` (one-time) or `application_fee_percent` (subscriptions).

#### One-time donation flow

1. Donor submits the form → `DonationsController#create` saves a **`pending`** `Donation` (as today).
2. Server creates a **Checkout Session**:

   ```ruby
   Stripe::Checkout::Session.create(
     mode: "payment",
     line_items: [{
       price_data: {
         currency: campaign.currency.downcase,   # "ils"
         unit_amount: donation.amount_cents,
         product_data: { name: campaign.title }
       },
       quantity: 1
     }],
     payment_intent_data: {
       transfer_data: { destination: organization.stripe_account_id },
       metadata: { donation_id: donation.id }
     },
     customer_email: donation.donor_email,
     success_url: campaign_url(campaign, payment: "success"),
     cancel_url: campaign_url(campaign, payment: "cancelled"),
     metadata: { donation_id: donation.id }
   )
   ```

3. Redirect the donor to `session.url`.
4. Stripe sends `checkout.session.completed` (and/or `payment_intent.succeeded`) to a **webhook** endpoint.
5. Webhook handler finds the donation by `metadata.donation_id`, stores `stripe_checkout_session_id` / `stripe_payment_intent_id`, and sets `status: "paid"`.
6. Change `Donation.counts_toward_progress` to **only `paid`** donations so abandoned checkouts do not inflate progress.

#### Recurring donations (הוראת קבע)

For monthly standing orders, use Checkout Session with `mode: "subscription"`:

- Create a **Price** (or inline `price_data` with `recurring: { interval: "month" }`).
- Pass `subscription_data: { metadata: { donation_id: … } }` and route to the connected account.
- Webhooks: `checkout.session.completed` creates the subscription; **`invoice.paid`** marks each installment/charge as paid.
- The existing `recurrence` field on `Donation` maps to one-time vs subscription; a `stripe_subscription_id` column would link the pledge to Stripe billing.

#### Database additions (minimal)

```ruby
# organizations
add_column :organizations, :stripe_account_id, :string
add_column :organizations, :stripe_onboarding_complete, :boolean, default: false

# donations
add_column :donations, :stripe_checkout_session_id, :string
add_column :donations, :stripe_payment_intent_id, :string
add_column :donations, :stripe_subscription_id, :string   # recurring only
add_column :donations, :paid_at, :datetime
```

#### Rails wiring (sketch)

- `gem "stripe"` + `STRIPE_SECRET_KEY` / `STRIPE_WEBHOOK_SECRET` in credentials/env.
- `StripeWebhooksController` — verify signature, handle events idempotently.
- `DonationsController#create` — after `@donation.save`, create Checkout Session and `redirect_to session.url, allow_other_host: true`.
- Optional `CheckoutController#success` — show a thank-you page only; **do not** flip `pending → paid` here (the redirect is not trusted).

#### Why Checkout Session over embedded Elements?

This app is server-rendered ERB with no React. **Stripe Checkout** (via Checkout Session) is the smallest integration: Stripe hosts PCI-sensitive card entry, supports ILS, Connect, and subscriptions, and fits the current redirect-based flow with minimal frontend work.

## Production deploy (AWS: Kamal + EC2 + RDS)

Infrastructure lives in **eu-west-1** (EC2 + RDS PostgreSQL + ECR). Kamal deploys the Docker image from [`Dockerfile`](Dockerfile) to the EC2 host.

### One-time AWS setup

```bash
# Requires AWS CLI (aws configure)
bash bin/provision-aws
source .aws-deploy.env   # or: export $(grep -v '^#' .aws-deploy.env | xargs)
```

Update [`config/deploy.yml`](config/deploy.yml) if the Elastic IP changes. SSH key: `.ssh/jgive-deploy.pem` (gitignored).

### Deploy commands

```bash
export DATABASE_URL="postgres://postgres:PASSWORD@RDS_ENDPOINT:5432/jgive_production"
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 339712701096.dkr.ecr.eu-west-1.amazonaws.com

bin/kamal setup    # first time only
bin/kamal deploy
bin/kamal app exec "bin/rails db:seed"
```

### Verify

```bash
curl http://ELASTIC_IP/up          # health check
curl http://ELASTIC_IP/            # campaigns index
bin/kamal logs
```

### Custom domain + SSL

1. Point DNS A record to the Elastic IP in `config/deploy.yml`.
2. Uncomment `proxy.ssl` / `proxy.host` in `config/deploy.yml`.
3. Set `FORCE_SSL: true` and `APP_PROTOCOL: https` in deploy env; redeploy.

### GitHub Actions

[`.github/workflows/deploy.yml`](.github/workflows/deploy.yml) deploys on push to `main` after tests pass. Required secrets: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `RAILS_MASTER_KEY`, `DATABASE_URL`, `SSH_PRIVATE_KEY`.
