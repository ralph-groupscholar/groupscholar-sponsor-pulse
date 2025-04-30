CREATE SCHEMA IF NOT EXISTS groupscholar_sponsor_pulse;

CREATE TABLE IF NOT EXISTS groupscholar_sponsor_pulse.sponsors (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  segment TEXT NOT NULL,
  owner TEXT NOT NULL,
  notes TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS groupscholar_sponsor_pulse.interactions (
  id SERIAL PRIMARY KEY,
  sponsor_id INT NOT NULL REFERENCES groupscholar_sponsor_pulse.sponsors(id),
  contact_date DATE NOT NULL,
  channel TEXT NOT NULL,
  summary TEXT NOT NULL,
  next_step TEXT NOT NULL DEFAULT '',
  sentiment INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_groupscholar_sponsor_pulse_interactions_date
  ON groupscholar_sponsor_pulse.interactions(contact_date);
