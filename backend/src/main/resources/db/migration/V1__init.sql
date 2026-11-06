-- KÖDER schema. Every table that holds personal data cascades from profiles,
-- so "delete my account" (DSGVO Art. 17) is one DELETE.

CREATE TABLE organizations (
    id         uuid PRIMARY KEY,
    name       text NOT NULL,
    industry   text,
    plan       text NOT NULL DEFAULT 'team',
    seats      int  NOT NULL DEFAULT 0,
    join_code  text UNIQUE,
    is_demo    boolean NOT NULL DEFAULT false,
    settings   jsonb NOT NULL DEFAULT '{}'
);

CREATE TABLE departments (
    id        uuid PRIMARY KEY,
    org_id    uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name      text NOT NULL,
    headcount int  NOT NULL DEFAULT 0,
    UNIQUE (org_id, name)
);

CREATE TABLE profiles (
    id            uuid PRIMARY KEY,
    device_id     text UNIQUE,
    email         text UNIQUE,
    password_hash text,
    display_name  text NOT NULL,
    avatar        int  NOT NULL DEFAULT 0,
    locale        text NOT NULL DEFAULT 'de',
    mode          text NOT NULL DEFAULT 'standard',
    role          text NOT NULL DEFAULT 'EMPLOYEE',
    org_id        uuid REFERENCES organizations(id) ON DELETE SET NULL,
    public_board  boolean NOT NULL DEFAULT true,
    created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE memberships (
    user_id       uuid PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    org_id        uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    department_id uuid REFERENCES departments(id) ON DELETE SET NULL,
    role          text NOT NULL DEFAULT 'EMPLOYEE'
);

-- Scenarios come from /content at startup (org_id NULL) or from a company's own pack.
CREATE TABLE scenarios (
    id          text NOT NULL,
    locale      text NOT NULL,
    org_id      uuid REFERENCES organizations(id) ON DELETE CASCADE,
    type        text NOT NULL,
    is_attack   boolean NOT NULL,
    attack_type text,
    difficulty  text NOT NULL,
    module      int  NOT NULL,
    status      text NOT NULL DEFAULT 'published',
    doc         jsonb NOT NULL,
    created_at  timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (id, locale)
);
CREATE INDEX scenarios_pool_idx ON scenarios (locale, org_id, status);

CREATE TABLE daily_shifts (
    id           uuid PRIMARY KEY,
    user_id      uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    date         date NOT NULL,
    scenarios    text NOT NULL,
    completed    boolean NOT NULL DEFAULT false,
    score        int NOT NULL DEFAULT 0,
    correct      int NOT NULL DEFAULT 0,
    swipe_rounds int NOT NULL DEFAULT 0,
    UNIQUE (user_id, date)
);

CREATE TABLE attempts (
    id          uuid PRIMARY KEY,
    user_id     uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    scenario_id text NOT NULL,
    locale      text NOT NULL,
    shift_id    uuid REFERENCES daily_shifts(id) ON DELETE CASCADE,
    context     text NOT NULL,
    action      text NOT NULL,
    outcome     text NOT NULL,
    is_correct  boolean NOT NULL,
    points      int NOT NULL,
    response_ms int NOT NULL,
    flags_found int NOT NULL DEFAULT 0,
    created_at  timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX attempts_user_idx ON attempts (user_id, created_at);
CREATE UNIQUE INDEX attempts_shift_once ON attempts (shift_id, scenario_id) WHERE shift_id IS NOT NULL;

CREATE TABLE review_queue (
    user_id     uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    scenario_id text NOT NULL,
    box         int  NOT NULL DEFAULT 1,
    due_at      timestamptz NOT NULL,
    PRIMARY KEY (user_id, scenario_id)
);

CREATE TABLE player_progress (
    user_id          uuid PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    xp               int NOT NULL DEFAULT 0,
    coins            int NOT NULL DEFAULT 0,
    streak           int NOT NULL DEFAULT 0,
    best_streak      int NOT NULL DEFAULT 0,
    last_active      date,
    streak_freezes   int NOT NULL DEFAULT 1,
    shifts_done      int NOT NULL DEFAULT 0,
    attacks_reported int NOT NULL DEFAULT 0,
    attacks_seen     int NOT NULL DEFAULT 0,
    times_hacked     int NOT NULL DEFAULT 0,
    false_alarms     int NOT NULL DEFAULT 0,
    answers          int NOT NULL DEFAULT 0,
    answers_correct  int NOT NULL DEFAULT 0
);

CREATE TABLE user_badges (
    user_id   uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    badge     text NOT NULL,
    earned_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, badge)
);

CREATE TABLE league_members (
    user_id   uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    week      text NOT NULL,
    tier      text NOT NULL DEFAULT 'bronze',
    weekly_xp int  NOT NULL DEFAULT 0,
    PRIMARY KEY (user_id, week)
);
CREATE INDEX league_week_idx ON league_members (week, tier, weekly_xp DESC);

CREATE TABLE duel_ratings (
    user_id uuid PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    elo     int NOT NULL DEFAULT 1000,
    wins    int NOT NULL DEFAULT 0,
    losses  int NOT NULL DEFAULT 0,
    draws   int NOT NULL DEFAULT 0
);

CREATE TABLE matches (
    id          uuid PRIMARY KEY,
    mode        text NOT NULL,
    seed        bigint NOT NULL,
    status      text NOT NULL,
    player_a    uuid REFERENCES profiles(id) ON DELETE SET NULL,
    player_b    uuid REFERENCES profiles(id) ON DELETE SET NULL,
    bot_name    text,
    score_a     int NOT NULL DEFAULT 0,
    score_b     int NOT NULL DEFAULT 0,
    winner      text,
    elo_delta_a int NOT NULL DEFAULT 0,
    elo_delta_b int NOT NULL DEFAULT 0,
    created_at  timestamptz NOT NULL DEFAULT now(),
    finished_at timestamptz
);

CREATE TABLE match_rounds (
    match_id    uuid NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    round_no    int  NOT NULL,
    scenario_id text NOT NULL,
    kind        text NOT NULL,
    answer_a    text,
    answer_b    text,
    ms_a        int,
    ms_b        int,
    points_a    int NOT NULL DEFAULT 0,
    points_b    int NOT NULL DEFAULT 0,
    PRIMARY KEY (match_id, round_no)
);

-- Company analytics are stored WITHOUT a user id: the employer physically cannot
-- reconstruct who clicked what. This is the Betriebsrat argument, by design.
CREATE TABLE org_stats (
    org_id        uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    department_id uuid NOT NULL REFERENCES departments(id) ON DELETE CASCADE,
    day           date NOT NULL,
    attack_type   text NOT NULL,
    answers       int NOT NULL DEFAULT 0,
    correct       int NOT NULL DEFAULT 0,
    hacked        int NOT NULL DEFAULT 0,
    reported      int NOT NULL DEFAULT 0,
    attacks       int NOT NULL DEFAULT 0,
    false_alarms  int NOT NULL DEFAULT 0,
    PRIMARY KEY (department_id, day, attack_type)
);
CREATE INDEX org_stats_org_idx ON org_stats (org_id, day);
