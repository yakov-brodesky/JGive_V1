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
