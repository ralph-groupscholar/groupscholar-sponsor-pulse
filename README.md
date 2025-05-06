# Group Scholar Sponsor Pulse

Sponsor Pulse is a Dart CLI for tracking sponsor relationships, logging interactions, and generating weekly summaries for development and partnership teams.

## Features

- Add sponsors with segments, owners, and notes.
- Log interactions with sentiment, channel, and next-step details.
- Review recent interactions by time window.
- Generate weekly sponsor pulse summaries.

## Tech Stack

- Dart CLI
- PostgreSQL (production)

## Setup

1. Install dependencies:

```bash
dart pub get
```

2. Configure environment variables (production credentials must be supplied via deployment tooling):

```bash
export GS_SPONSOR_PULSE_DB_HOST=your-host
export GS_SPONSOR_PULSE_DB_PORT=23947
export GS_SPONSOR_PULSE_DB_NAME=postgres
export GS_SPONSOR_PULSE_DB_USER=ralph
export GS_SPONSOR_PULSE_DB_PASSWORD=your-password
export GS_SPONSOR_PULSE_DB_SSLMODE=disable
```

3. Run a command:

```bash
dart run bin/groupscholar_sponsor_pulse.dart list-sponsors
```

## Commands

- `add-sponsor --name --segment --owner [--notes]`
- `log-interaction --sponsor --date --channel --summary [--next-step] [--sentiment]`
- `list-sponsors [--limit]`
- `recent-interactions [--days]`
- `weekly-summary [--weeks]`
- `sponsor-health [--recency-days] [--sentiment-days] [--stale-days] [--warm-days]`

## Database

The schema lives in `db/schema.sql`. Apply it to production before first use, then seed with `db/seed.sql`.

## Testing

```bash
dart test
```
