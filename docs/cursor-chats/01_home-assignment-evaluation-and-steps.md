# Home assignment evaluation and steps
_Exported on 6/22/2026 at 13:34:20 GMT+3 from Cursor (3.3.22)_

---

**User**

So I was asked for a job application to do a home assignment,.
I'll add here 2 things.
1. a URL that I want you to explore: https://www.jgive.com/new/he/ils/donation-targets/159183 
2. a PDf file with the assignemnt.

@c:\Users\yakov\AppData\Roaming\Cursor\User\workspaceStorage\6d7d614b95652d4ebc19d6dfc769cc4a\pdfs\72bcdab5-2fe3-4606-971f-6499fc9a939b\jgive-backend-home-assignment.md.pdf 

This is the 1st step and I need you to tell me
is it doable and what are the main steps needed to be done to acheive it

---

**Cursor**

I’ll review the assignment PDF and inspect the donation page enough to judge feasibility, then I’ll summarize whether it’s doable and the main implementation steps without changing anything.

The PDF is clear: it’s a small Rails app reproducing one Jgive campaign page through pending donation submission, with deployment and README required. I’m going to inspect the live page structure next so the feasibility estimate reflects the actual UI, not just the assignment text.

The assignment is intentionally bounded: no auth, no checkout, no production hardening. The biggest unknown is the amount of visual fidelity expected from the public campaign page, so I’m checking the live page layout and interactions.

The browser initially landed on a loading state, so I’ll give it a short wait and then capture the rendered structure/screenshot once the app hydrates.

The live page has a top visual hero, RTL Hebrew campaign content, progress metrics, tab navigation, and a prominent donation CTA. I’m going one level deeper into the donation interaction to confirm what form fields should be mirrored.

I confirmed the donation modal: the real site has amount presets, one-time/monthly choice, optional comment, dedication toggle, visibility preference, rounding, and then a disabled continue until an amount is selected. The assignment only requires a focused subset of that, so the implementation can stay manageable.

---

**User**

so here's something you need to know, I haven't worked with Ruby on Rails, but I did work with Postresql, Graphql and rEact.
Also From the PDF it looks like I need to put it somewhere on the cloud (AWS) and give them access.
so this should also be part of the paln

---

**Cursor**

Got it. I’ll adjust the plan to reflect your background: lean on Rails as the new piece, use PostgreSQL deliberately, keep React/GraphQL out unless there’s a strong reason, and include AWS deployment/access as an explicit deliverable.

I found the existing plan file. I’m updating it now so it explicitly treats Rails as the learning curve, PostgreSQL as the database choice, and AWS deployment as part of the delivery path.

Updated the plan to include your background and AWS deployment.

Key adjustment: I’d **not** use React or GraphQL unless they ask for it. Since this is a **Ruby on Rails backend assignment**, the stronger signal is an idiomatic Rails app with PostgreSQL, Active Record models, validations, server-rendered views, tests, seeds, README, and deployment.

For cloud, the plan now includes AWS explicitly. Best practical options:

- **AWS App Runner + RDS PostgreSQL**: clean, modern, good if we containerize.
- **Elastic Beanstalk + RDS PostgreSQL**: often faster for a simple Rails app.
- Avoid complex AWS setup like Terraform/VPC/CI unless needed.

So yes, still doable, but we should protect time for two harder parts: learning enough Rails conventions and getting AWS deployment working early, not at the last minute.

---

**User**

does the RoR also has a frontend part ?

---

**Cursor**

Yes. Ruby on Rails can include the frontend too.

Rails is a full-stack framework, so a typical Rails app has:

- **Backend**: models, database migrations, controllers, validations, business logic.
- **Frontend**: HTML views, forms, layouts, CSS, JavaScript.
- **Database layer**: usually through Active Record.
- **Routing**: maps URLs to controller actions.

For this assignment, you can build the frontend with regular Rails views, usually ERB templates:

```erb
<h1><%= @campaign.title %></h1>
<%= form_with model: [@campaign, @donation] do |form| %>
  <%= form.number_field :amount %>
  <%= form.submit "Donate" %>
<% end %>
```

So you do **not** need React for this. Rails can render the campaign page, tabs, donation form, validation errors, and success state directly.

Rails also has **Hotwire/Turbo**, which gives some modern frontend behavior without building a separate React app. For this assignment, plain Rails views plus a little CSS/JS should be enough.

---

**User**

if you look at the job description:
https://www.nbn.org.il/jobboard/job/senior-full-stack-developer-5/ 
you can see they do ask as a bonus for react, so why not Postgresql + RoR + GraphQL as backend + react as front ?

---

**Cursor**

That stack is technically valid and it matches the broader job description better, but it changes the assignment from “small Rails app” into “full-stack platform slice,” so the trade-off is worth deciding deliberately.

**Choose Assignment Stack**

> **Which implementation direction do you want the plan to target?**
> - Rails + PostgreSQL + GraphQL + React to showcase the job's full-stack bonus skills
> - Rails + PostgreSQL + Rails views, with README explaining React/GraphQL extension path (Recommended for assignment scope)
> - Rails + PostgreSQL backend with a small React donation widget only

---

**User**

how much harder is going to be ?

try again

---

**Cursor**

It depends what “harder” means: coding difficulty, Rails learning curve, or delivery risk. Compared to plain Rails, I’d estimate:

**Rails + PostgreSQL + Rails frontend**
Difficulty: **5/10**  
Time: **4-6 hours**  
Risk: mostly learning Rails conventions and deploying.

**Rails + PostgreSQL + GraphQL + React**
Difficulty: **8/10**  
Time: **10-16 hours** for a clean version  
Risk: much higher, because you must make Rails, GraphQL, React, assets, validations, and AWS deployment all work together.

Why it gets harder:

- You build **two layers of UI/data flow** instead of Rails forms.
- Every form action becomes a **GraphQL mutation**.
- Every screen needs **React state**, loading states, error handling, and refetch/update logic.
- You need to decide whether React is inside Rails or a separate app.
- Deployment becomes trickier, especially on AWS.
- The assignment asks for 4-6 hours, so a bigger stack can look like poor scope control if unfinished.

My honest recommendation: **don’t do full React + GraphQL for v1**.

Better senior approach:

Build the assignment with **Rails + PostgreSQL + Rails views**, but make the code structured so you can say:

> “I kept this idiomatic Rails to respect the assignment scope. Given more time, I would expose the donation flow through GraphQL and move the donation form/progress UI into React.”

If you really want to show React, the safest compromise is:

**Rails + PostgreSQL + Rails views + one small React donation component**
Difficulty: **6.5/10**  
Time: **6-9 hours**  
This shows React without turning the whole assignment into a full-stack rebuild.

---

**User**

ok, so maybe let's go back to the 1st simpler version

---

**Cursor**

Agreed. I’ll tighten the plan back around the simpler Rails-first implementation: Rails views for the UI, PostgreSQL for data, no React/GraphQL in v1, and AWS deployment still included as a deliverable.

The plan already mostly points this way; I’m making the scope statement explicit so the next implementation phase doesn’t drift back toward React/GraphQL.

Yes, let’s go with the simpler version.

Updated the plan to make that explicit:

**Chosen stack:**
- Ruby on Rails
- PostgreSQL
- Rails server-rendered frontend/views
- Rails forms/controllers/models
- AWS deployment
- No React
- No GraphQL

React/GraphQL can be mentioned in the README as future improvements, but not built now. That keeps the assignment aligned with the 4-6 hour scope and reduces the chance of getting stuck on integration/deployment.

---

**User**

ok, so what are the next steps ?

---

**Cursor**

Next steps:

1. **Confirm local setup**
   Check whether you have Ruby, Rails, PostgreSQL, Git, and AWS CLI installed.

2. **Create the Rails app**
   Generate a new Rails app using PostgreSQL:
   `rails new jgive_assignment -d postgresql`

3. **Build the core data model**
   Add:
   - `Campaign`
   - `Donation`
   - donation statuses: `pending`, `paid`
   - recurrence: one-time / recurring
   - display preference: full name / first name / anonymous

4. **Seed the campaign**
   Add the “הגן הכתום” campaign data, goal amount, raised amount, story text, image reference, and sample donations.

5. **Build the campaign page**
   Rails-rendered RTL page with:
   - hero image
   - title/subtitle
   - progress bar
   - tabs
   - campaign story
   - recent donations
   - donation button/form

6. **Build donation submission**
   Form creates a `pending` donation and updates/recalculates campaign progress. No payment.

7. **Add focused tests**
   Mainly model validation, donation creation, and progress calculation.

8. **Prepare README**
   Include:
   - local setup
   - deployment URL
   - design decisions
   - what was cut
   - how real payment integration would work
   - AI/tooling notes

9. **Deploy to AWS**
   Prefer simplest working AWS route:
   - App Runner or Elastic Beanstalk for Rails app
   - RDS PostgreSQL for database

10. **Prepare submission**
   Send:
   - GitHub repo link
   - live AWS URL
   - transcript(s)
   - short thought process/setup notes

Before building, the very next practical step is checking your machine setup: Ruby/Rails/PostgreSQL/AWS CLI.

---

**User**

ok, let's do it

---

**Cursor**

I’ll start by switching into implementation mode, then I’ll verify the local toolchain and workspace state before generating the Rails app.

I’m going to check what’s already in `C:\Users\yakov\Repos\JGive_V1` and whether Ruby/Rails/PostgreSQL/Git are available, so we generate the app in the right place and don’t overwrite anything.

Ruby, Rails, and `psql` are not installed on PATH; Git and AWS CLI are available. I’ll check whether Docker is available, because that may be the quickest way to build/run Rails without installing Ruby directly on Windows.

Because this machine doesn’t have Ruby/Rails installed but does have Docker, I’ll generate and run the Rails app through Docker. That keeps your Windows setup cleaner and still produces a normal Rails/PostgreSQL project.

The first Docker attempt pulled Ruby and installed the Rails gem, but the `rails` executable was not on PATH inside that container. I’ll rerun using RubyGems’ executable path directly.

The issue is currently container command quoting and Rails executable discovery, not the app itself. I’m narrowing it down with a direct executable path so we can generate once and move on.

Direct `/usr/local/bundle/bin/rails` works. I’ll generate the project now with PostgreSQL and a trimmed Rails feature set for this assignment.

---

**User**

what is the issue you're trying to solve ? I can see a docker image with ruby, but it's not running, do I need to run it  ?

---

**Cursor**

No, you don’t need to manually run that Docker image.

The issue I was solving: your Windows machine has **Docker**, but does **not** have Ruby/Rails/PostgreSQL tools installed on PATH:

- `ruby` missing
- `rails` missing
- `psql` missing
- Docker is available

So I’m using Docker only as a temporary tool to **generate and run the Rails app** without installing Ruby directly on Windows. The `ruby:3.3` image is expected to appear and then stop; `docker run --rm ...` starts a short-lived container, runs a command, then exits and removes the container.

What happened:
- Docker pulled the Ruby image successfully.
- Rails installed successfully inside the container.
- I hit some quoting/PATH issues on Windows PowerShell.
- Then the actual `rails new ...` command was interrupted before it completed.

So the Docker image not running is normal. We only need it running when executing a command.

Next, I can continue by generating the Rails app through Docker, but with a cleaner command. Since you asked, I’ll pause here: you don’t need to do anything manually unless you prefer installing Ruby/Rails locally instead of using Docker.

---

**User**

ok, so go on

---

**Cursor**

I’ll continue with the Docker-based setup. First I’ll check whether the interrupted `rails new` left any partial files, then I’ll either resume safely or regenerate cleanly in the same empty project folder.

The folder is still empty and not a git repo, so there’s nothing partial to clean up. I’ll run `rails new` again through the Ruby container and let it finish.

The Rails project is generated successfully, including Git initialization and a Dockerfile. Next I’ll inspect the generated Rails 8/PostgreSQL configuration and add a local `docker-compose.yml` so the app and database can run together.

The generated app uses Rails 8 defaults, including PostgreSQL and a production Dockerfile. I’m going to keep the app simple for local development by adding Docker Compose and pointing development/test DB config at the Compose PostgreSQL service.

I’ll add a local Compose file and adjust `database.yml` so Rails connects to the `db` service when running in Docker, while still using `DATABASE_URL` cleanly in production.

Now I’m adding `docker-compose.yml` with a Rails web service and PostgreSQL service, so local development can run without installing Ruby or PostgreSQL directly on Windows.

The Docker Compose setup is in place. I’ll run `db:prepare` through Compose next to verify Rails can install gems and connect to PostgreSQL.

Rails can now prepare the PostgreSQL databases through Compose, so local setup is verified. I’ll generate the core `Campaign` and `Donation` models next, using integer cents for money to avoid floating-point bugs.

The model files and migrations are generated. I’ll tighten them with defaults, associations, validations, and campaign progress helpers before migrating/seeding.

I’ll use cents as integers, set required columns/defaults in the migrations, and put the progress logic on `Campaign` so controllers/views stay simple.

Next I’ll add defaults and indexes to donations, so new donations naturally start as `pending` and query efficiently by campaign/status.

Now I’ll implement the model-level rules and helper methods: campaign totals/progress, donation enum values, display-name behavior, and validations.

The campaign model is set. I’ll add donation validations and display logic next, including anonymous and first-name-only display preferences.

I’ll seed the main Jgive campaign and a few sample donations so the page has realistic progress and recent activity immediately after setup.

The seed data is ready. I’ll migrate and seed through Docker Compose now, then move into the campaign page and donation flow.

---

**User**

wait, did the initial setup is done ?  if so we didn't speak at all about the data model ?
can you give me a handover prompt so I can start a new chat focusing on that

---

**Cursor**

Yes, the initial setup is basically done, and you’re right: I moved into a first-pass data model based on the assignment before we discussed it deeply.

Use this handover prompt for a new chat:

```text
We are building a Ruby on Rails home assignment for Jgive.

Assignment summary:
Build a small Rails app that reproduces this Jgive campaign donation page:
https://www.jgive.com/new/he/ils/donation-targets/159183

Scope:
- Ruby on Rails app
- PostgreSQL
- Rails server-rendered frontend, no React/GraphQL for v1
- Donation flow only up to creating a pending donation
- No payment/checkout
- Seed one or two campaigns and sample donations
- Deploy later to AWS
- README should explain local setup, decisions/trade-offs, future payment integration, and AI usage

Current setup already done:
- Rails app generated in `C:\Users\yakov\Repos\JGive_V1`
- Docker-based local development because Ruby/Rails/PostgreSQL are not installed locally
- `docker-compose.yml` added with:
  - `web` service using `ruby:3.3`
  - `db` service using `postgres:16`
- `config/database.yml` adjusted to use env vars:
  - `DB_HOST`
  - `DB_USERNAME`
  - `DB_PASSWORD`
  - `DATABASE_URL` in production
- `bin/rails db:prepare` worked through Docker Compose
- Git repo initialized by Rails, but no commit has been made yet

First-pass data model already generated:
- `Campaign`
- `Donation`

Files already touched:
- `config/database.yml`
- `docker-compose.yml`
- `app/models/campaign.rb`
- `app/models/donation.rb`
- `db/migrate/20260617091246_create_campaigns.rb`
- `db/migrate/20260617091259_create_donations.rb`
- `db/seeds.rb`

Current model assumptions:
Campaign fields:
- title
- subtitle
- organization_name
- organization_category
- organization_city
- organization_registration_number
- organization_email
- organization_phone
- organization_website
- cover_image_url
- goal_amount_cents
- initial_raised_amount_cents
- donor_count
- story

Donation fields:
- campaign_id
- donor_name
- amount_cents
- recurrence: `one_time` / `monthly`
- display_preference: `full_name` / `first_name` / `anonymous`
- dedication_message
- note
- status: `pending` / `paid`

Important: I want to pause and review whether this is the right data model before continuing. Please help me think through the data model for this assignment like a senior Rails/backend engineer:
- Is Campaign + Donation enough?
- Should organization/nonprofit be its own model or embedded in Campaign?
- Should campaign progress include pending donations or only paid donations?
- How should we model pending vs paid given the assignment says pending should update progress, but real payment would only count paid?
- Are `initial_raised_amount_cents` and `donor_count` good seed shortcuts, or should everything come from donations?
- What validations and enums should exist?
- What should be intentionally left out for assignment scope?
- After discussion, update the model/migration plan if needed.
```

My recommendation for the new chat: start by asking it to **review the current data model before coding further**, especially the question of whether progress should count `pending`, `paid`, or both.

---

**User**

I need this entire chat coppied to a document. can you suggest the best format to do it ?

---

**Cursor**

For the Jgive assignment, the best approach is usually **two formats**:

## Recommended

1. **Markdown (`.md`)** — your working copy  
   - Easy to read and edit  
   - Works well in GitHub/the repo  
   - Can be converted cleanly to PDF  
   - Good if reviewers want to search or skim quickly  

2. **PDF** — what you actually submit  
   - Looks professional  
   - Layout stays fixed  
   - Matches what most hiring teams expect for “transcript” deliverables  

So: **keep Markdown as source, export PDF for submission**.

## Suggested structure

```markdown
# Jgive Home Assignment — AI Chat Transcript

## Metadata
- Tool: Cursor
- Model: [model name if you know it]
- Date range: [start] – [end]
- Purpose: Planning and implementation of Rails home assignment

---

## Conversation

### User
[paste message]

### Assistant
[paste message]

...
```

That format is much easier to review than one giant unbroken block of text.

## What to include

Include the full conversation, especially:

- Assignment review and feasibility  
- Stack decisions (Rails vs React/GraphQL)  
- Data model discussion  
- Docker/setup notes  
- Any implementation decisions  
- This handover/export discussion  

You can lightly trim only obvious noise like repeated “try again” if the substance is preserved.

## How to get it out of Cursor

Best options, in order:

1. **Select all in chat and copy**  
   - Fastest  
   - Then paste into a `.md` file and clean up headings  

2. **Export from Cursor if available**  
   - Some versions have chat export/share  
   - If you see it, use that first  

3. **Use the transcript file if present**  
   - Cursor may store chats under something like:  
     `C:\Users\yakov\.cursor\projects\c-Users-yakov-Repos-JGive-V1\agent-transcripts\`
   - Those are often `.jsonl` and are **not** submission-ready by themselves  
   - They’re useful as backup, but you’ll want to convert to Markdown/PDF  

## What I would submit

Put this in the repo:

- `docs/ai-transcript.md`

And send them:

- `docs/ai-transcript.pdf`

If you only want one file for submission: **PDF**.  
If you want the best long-term setup: **Markdown + PDF**.

## Small tip for the assignment README

Add a short note like:

> Full AI chat transcript is included in `docs/ai-transcript.md` and `docs/ai-transcript.pdf`. It covers scope decisions, stack trade-offs, data model discussion, and setup approach.

That shows transparency without making them hunt for it.

If you want, I can give you a ready-made Markdown template file structure for `docs/ai-transcript.md` that you can paste this chat into.

---

**User**

how to copy allthis chat ?

---

**Cursor**

I'll check whether Cursor saved this conversation as a transcript file you can copy or export directly.


Here are the practical ways to copy this chat in Cursor:

## Option 1: Copy from the chat UI (simplest)

1. Click inside the chat panel.
2. Scroll to the **top** of the conversation.
3. Click once in the chat area.
4. Press `Ctrl + A` to select all messages in the chat.
5. Press `Ctrl + C` to copy.
6. Paste into a file like `docs/ai-transcript.md`.

If `Ctrl + A` only selects one message, do this instead:
- Scroll to the top
- Click the first message
- Hold `Shift`
- Scroll to the bottom and click the last message
- Then `Ctrl + C`

## Option 2: Use Cursor’s chat menu

At the top of the chat panel, open the `...` menu and look for something like:
- **Export chat**
- **Copy chat**
- **Share**

If you see it, use that — it’s the cleanest export.

Cursor’s exact menu labels can vary by version, so if you don’t see export, use Option 1 or 3.

## Option 3: Use the saved transcript file (best backup)

Cursor also saves chats locally. This conversation appears to be here:

`C:\Users\yakov\.cursor\projects\c-Users-yakov-Repos-JGive-V1\agent-transcripts\c7634a50-7677-49f4-aeae-e43ebe6e5132\c7634a50-7677-49f4-aeae-e43ebe6e5132.jsonl`

That file contains the full conversation, but in raw JSON format — not nice to submit as-is.

You can:
1. Open that file in Cursor/Notepad
2. Copy it
3. Convert it to readable Markdown/PDF

## Best workflow for the assignment

1. Copy from chat UI into `docs/ai-transcript.md`
2. Add a title at the top:
   ```markdown
   # Jgive Home Assignment — AI Chat Transcript
   Tool: Cursor
   Date: June 2026
   ```
3. Export that file to PDF for submission

## If you want, I can do the next step

I can convert the saved transcript file into a clean Markdown document in your repo, like:

`docs/ai-transcript.md`

That would be the easiest submission-ready version.

