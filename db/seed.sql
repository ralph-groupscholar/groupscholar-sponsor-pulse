INSERT INTO groupscholar_sponsor_pulse.sponsors (name, segment, owner, notes)
VALUES
  ('North Star Fund', 'National Foundation', 'Avery Kim', 'Renewal due in Q2.'),
  ('Aspire Foundation', 'Regional Partner', 'Samir Patel', 'Interested in STEM expansion.'),
  ('Harbor Giving Circle', 'Community Partner', 'Lena Torres', 'Prefers quarterly check-ins.'),
  ('Bright Futures Trust', 'Corporate Sponsor', 'Jordan Lee', 'Pilot cohort spotlight requested.');

INSERT INTO groupscholar_sponsor_pulse.interactions
  (sponsor_id, contact_date, channel, summary, next_step, sentiment)
SELECT id, DATE '2026-01-27', 'call',
  'Reviewed mid-year outcomes and discussed renewal path.',
  'Send updated outcomes slide deck.', 2
FROM groupscholar_sponsor_pulse.sponsors
WHERE name = 'North Star Fund';

INSERT INTO groupscholar_sponsor_pulse.interactions
  (sponsor_id, contact_date, channel, summary, next_step, sentiment)
SELECT id, DATE '2026-01-29', 'email',
  'Shared STEM expansion highlights and budget outline.',
  'Confirm interest in matching grant.', 1
FROM groupscholar_sponsor_pulse.sponsors
WHERE name = 'Aspire Foundation';

INSERT INTO groupscholar_sponsor_pulse.interactions
  (sponsor_id, contact_date, channel, summary, next_step, sentiment)
SELECT id, DATE '2026-02-03', 'meeting',
  'Presented cohort stories and secured volunteer ambassador.',
  'Coordinate ambassador onboarding.', 2
FROM groupscholar_sponsor_pulse.sponsors
WHERE name = 'Harbor Giving Circle';

INSERT INTO groupscholar_sponsor_pulse.interactions
  (sponsor_id, contact_date, channel, summary, next_step, sentiment)
SELECT id, DATE '2026-02-05', 'email',
  'Sent pilot cohort spotlight and media kit.',
  'Schedule follow-up call for Q3 planning.', 1
FROM groupscholar_sponsor_pulse.sponsors
WHERE name = 'Bright Futures Trust';
