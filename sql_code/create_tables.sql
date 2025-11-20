SET search_path TO nba;

DROP TABLE IF EXISTS fact_player_season;
DROP TABLE IF EXISTS dim_team;
DROP TABLE IF EXISTS dim_season;
DROP TABLE IF EXISTS dim_player;

CREATE TABLE IF NOT EXISTS dim_season (
  season_key INT PRIMARY KEY,
  start_year INT
);

CREATE TABLE IF NOT EXISTS dim_player (
  player_key VARCHAR(15) PRIMARY KEY,
  full_name VARCHAR(200) NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_team (
  team_key VARCHAR(3) PRIMARY KEY,
  team_name VARCHAR(30),
  conference VARCHAR(16)
);

CREATE TABLE IF NOT EXISTS fact_player_season (
  player_key VARCHAR(15) REFERENCES dim_player(player_key),
  team_key VARCHAR(3) REFERENCES dim_team(team_key),
  season_key INT REFERENCES dim_season(season_key),
  pos VARCHAR(5),
  g INT,
  gs INT,
  perce DECIMAL(7,2),
  ts_per DECIMAL(7,3),
  usg_per DECIMAL(7,2),
  ws DECIMAL(7,2),
  bpm DECIMAL(7,2),
  vorp DECIMAL(7,2),
  mp INT,
  age	INT,
  salary DECIMAL(12,2),
  value DECIMAL(18,6),
  deserved_salary DECIMAL(18,2),
  salary_gap DECIMAL(18,2),
  overpaid_underpaid DECIMAL(18,2),
  fair_value BOOLEAN,
  PRIMARY KEY (player_key, team_key, season_key)
);
