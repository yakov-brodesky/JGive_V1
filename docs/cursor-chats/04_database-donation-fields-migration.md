# Database donation fields migration
_Exported on 6/22/2026 at 13:37:36 GMT+3 from Cursor (3.3.22)_

---

**User**

Database new donation fields.
1. does the local db have the up to date changes ?
can we run the migratiojs ?

---

**Cursor**

I'll check the donation-related migrations and compare them with your local database state.


---

**User**

what is the command to run the db migration locally ?

---

**Cursor**

Checking how this project expects migrations to be run locally.


For this project, the local migration command is:

```bash
bin/rails db:migrate
```

If the database does not exist yet, use:

```bash
bin/rails db:prepare
```

That creates the DB if needed and runs pending migrations.

---

Since this app uses PostgreSQL via Docker, the usual local flow on Windows is:

**1. Start Postgres**
```powershell
docker compose up -d db
```

**2. Run migrations inside the Rails container**
```powershell
docker compose run --rm web bin/rails db:migrate
```

Or, if the `web` container is already running:
```powershell
docker compose exec web bin/rails db:migrate
```

**3. Optional: seed sample data**
```powershell
docker compose run --rm web bin/rails db:seed
```

---

**Check migration status**
```powershell
docker compose run --rm web bin/rails db:migrate:status
```

You should see all 3 migrations up, including `20260617091259_create_donations`, which adds the new donation fields (`recurrence`, `display_preference`, `dedication_message`, `note`, `status`, etc.).

If you have Ruby installed locally and `bundle` works, you can skip Docker for the Rails command and run `bin/rails db:migrate` directly — but Postgres still needs to be running (`docker compose up -d db`).

---

**User**

I've noticed we have a few free text fields for dedication message, comment and who to send it,
it appears to me that you put them all inside the deciation_message field.

"כבוד dedication for Ms Bobo | this is a personal message field | נשלח ל: yakov.brodesky@gmail.com"

קראו עוד

I think we may want to split them into more than just one long concatinted field 
we also have 2 versionS:
"In-Memory of" and "Dedicated to" 
can we plan for extending the donations table fields ?

---

**Cursor**

I'll trace how dedication and comment fields are stored and rendered today, then draft a plan to split them into proper columns.


Confirming: `note` is already separate; only dedication fields are concatenated in the controller. Creating the plan.


---

**User**

there's also a small difference between the dedication for memory of and for someone who is alive
there's an extra field "memory of""

---

**Cursor**

Checking how the form handles the "in memory of" vs "dedicated to" flows and whether the extra recipient field exists in code.


Adding the memory-only recipient field to the plan — it's missing from the current form and schema.


Good catch — the screenshots show a real difference between the two flows, and the current code doesn't implement it yet.

**לכבוד (honor):**
- לכבוד מי ההקדשה
- אימייל לשליחה
- הודעה אישית

**לזכר (memory):**
- לזכר מי ההקדשה
- **למי תשלח ההקדשה** ← extra field (living recipient)
- אימייל לשליחה
- הודעה אישית

The Stimulus controller only swaps the honoree label today; it never shows the recipient-name field.

I've updated the plan to add a fourth column:

| Column | Purpose |
|---|---|
| `dedication_recipient_name` | Living person who receives the notification — **required for memory, hidden/unused for honor** |

This also means:
- **Form**: add the missing "למי תשלח ההקדשה" field, shown only when לזכר is selected
- **Stimulus**: show/hide that field on type change; clear it when switching back to honor
- **Model**: validate `dedication_recipient_name` only when `memory?`
- **Controller**: nil out `dedication_recipient_name` when type is honor

The plan is updated. Say the word when you want me to implement it.

---

**User**

obviously all those fields are nullable (as you can see)

---

**Cursor**

Updating the plan to state explicitly that all dedication fields are nullable at the DB level, with validations only when dedication is enabled.


Right — the plan now states this explicitly:

**Database:** all dedication columns (`dedication_type`, `dedication_honoree`, `dedication_recipient_name`, `dedication_recipient_email`, `dedication_message`) plus `note` are **nullable** — no `null: false` in the migration.

**When dedication is off:** everything stays `null` (same pattern as `note` today).

**When dedication is on:** the UI `*` markers map to conditional validations only — honoree and email required, recipient name required for memory only, personal message always optional.

DB nullability and UI required-ness stay separate. Ready to implement when you are.

---

**User**

do you think there's a point to keep those fields in a jsonb field type ?
and then the whole filed can be nullable ?

---

**Cursor**

For this app, I'd lean toward separate nullable columns — but JSONB is reasonable if you expect the dedication shape to keep changing.


**Dedication storage approach**

> **Which approach should the plan use for dedication data?**
> - Separate nullable columns (recommended for this app — simpler forms, search, validations) ✔
> - Single nullable JSONB column (e.g. dedication: { type, honoree, recipient_name, recipient_email, message })
> - Hybrid: keep note as its own column; store dedication sub-fields in one JSONB column

**Short answer:** JSONB can work, but for this app separate nullable columns are the better fit — and that's what we'll keep in the plan.

**JSONB pros**
- One nullable column when dedication is off (`dedication = null`)
- Easy to add fields later without migrations
- Groups the whole dedication "bundle" conceptually

**JSONB cons (relevant here)**
- Search gets awkward — [`campaigns_controller.rb`](app/controllers/campaigns_controller.rb) uses simple `ILIKE` on columns; JSONB needs path queries like `dedication->>'honoree'`
- Forms and validations are less idiomatic — you'd need virtual accessors or a wrapper object instead of `form.text_field :dedication_honoree`
- Honor vs memory conditional rules are clearer with explicit columns + `validates ... if: :memory?`
- The field set is small and stable (5 fields) — JSONB is more useful when the shape changes often

**Recommendation:** keep separate nullable columns. `note` stays its own column (different concern — public campaign comment). Dedication fields get their own columns, all nullable, with conditional validations when the toggle is on.

The plan already reflects this. Say the word when you want me to implement it.

---

**User**

ok, so let's do the migration

---

**Cursor**

Implementing the migration and related code changes from the plan.


Plan mode blocked code edits — switching to agent mode to implement the migration.


The migration and related code changes are ready to implement, but I'm still in **plan mode**, which blocks edits to Ruby and other source files. Switch to **agent mode** and ask again (e.g. "implement the migration") and I'll apply everything.

Here's what will be created:

**Migration** — `db/migrate/20260617230000_add_dedication_fields_to_donations.rb`:

```ruby
class AddDedicationFieldsToDonations < ActiveRecord::Migration[8.1]
  def change
    add_column :donations, :dedication_type, :string
    add_column :donations, :dedication_honoree, :string
    add_column :donations, :dedication_recipient_name, :string
    add_column :donations, :dedication_recipient_email, :string
  end
end
```

All four columns are nullable. Existing `dedication_message` and `note` stay as-is.

**Run locally:**

```powershell
docker compose up -d db
docker compose run --rm web bin/rails db:migrate
```

**Full implementation** (after mode switch) also includes:
- Model enum + conditional validations
- Controller: stop concatenating; persist fields directly
- Form + Stimulus: add memory-only "למי תשלח ההקדשה" field
- Donor card display + search updates
- Seeds, fixtures, tests

Switch to agent mode when you're ready and I'll implement the full plan.

---

**User**

let's add the new columsn and run the migration

---

**Cursor**

I'll add the migration and related code changes, then run it locally.


Migration ran successfully. Here's what was done:

**New columns** (all nullable):
- `dedication_type` — `"honor"` or `"memory"`
- `dedication_honoree` — who is being honored/remembered
- `dedication_recipient_name` — living recipient (memory flow only)
- `dedication_recipient_email` — email to send notification

**Migration output:**
```
== 20260617230000 AddDedicationFieldsToDonations: migrated (0.0404s) ==========
```

**Also updated:**
- Model — enum, conditional validations, `dedication_summary` helper
- Controller — stops concatenating; persists each field directly
- Form — binds to model attributes; adds "למי תשלח ההקדשה" for memory
- Stimulus — shows/hides recipient name field by type
- Donor card — shows structured dedication (summary + personal message)
- Search — includes all new dedication fields
- Seeds, fixtures, tests — all 7 tests passing

To re-seed with structured sample data:
```powershell
docker compose run --rm web bin/rails db:seed
```

