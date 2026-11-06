-- Shifts are repeatable: any number per day, numbered within the day. Swipe rounds are no longer limited.
ALTER TABLE daily_shifts ADD COLUMN round int NOT NULL DEFAULT 1;
ALTER TABLE daily_shifts DROP COLUMN swipe_rounds;
ALTER TABLE daily_shifts DROP CONSTRAINT daily_shifts_user_id_date_key;
ALTER TABLE daily_shifts ADD CONSTRAINT daily_shifts_user_date_round UNIQUE (user_id, date, round);

-- A manager can pin the difficulty for a whole company, for a demonstration or to check a level.
CREATE TABLE content_settings (
    org_id            uuid PRIMARY KEY REFERENCES organizations(id) ON DELETE CASCADE,
    forced_difficulty text CHECK (forced_difficulty IN ('bronze', 'silver', 'gold', 'diamond'))
);
