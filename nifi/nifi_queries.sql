-- Dim_team_etl Process Group
-- Flow: ListS3 --> FetchS3Object --> QueryRecord --> UpdateAttribute --> PutS3Object
-- QueryRecord to set team abbreviation as team_key, team name as team_name, and conference
-- Outputted to S3 as dim_team.csv

SELECT
    abbreviation AS team_key,
    team AS team_name,
    conference
FROM FLOWFILE

-- Dim_season_etl Process Group
-- Flow: ListS3 --> FetchS3Object --> QueryRecord --> UpdateAttribute --> PutS3Object
-- QueryRecord to set end year of season as season_key and start year as start_date
-- Outputted to S3 as dim_season.csv

SELECT DISTINCT CAST(Season AS INTEGER) AS season_key, CAST(Season AS INTEGER) - 1 AS start_date
FROM FLOWFILE
WHERE CAST(Season AS INTEGER) BETWEEN 2021 AND 2025

-- Dim_season_etl Process Group
-- Flow: ListS3 --> FetchS3Object --> QueryRecord --> UpdateAttribute --> MergeRecord -->
-- UpdateAttribute --> PutS3Object
-- QueryRecord to set player key and full name
-- Outputted to S3 as dim_player.csv

SELECT DISTINCT
    "Player-additional" AS player_key,
    Player AS full_name
FROM FLOWFILE

-- Fact_etl Process Group
-- Flow: ListS3 --> FetchS3Object --> UpdateAttribute --> UpdateAttribute --> UpdateRecord -->
-- UpdateRecord --> ExecuteStreamCommand --> QueryRecord --> UpdateAttribute --> MergeRecord -->
-- UpdateAttribute --> PutS3Object
-- QueryRecord to choose keys and stats for all players
-- Outputted to S3 as dim_player.csv

SELECT
    player_key,
    Team AS team_key,
    Season AS season_key,
    POS as pos VARCHAR(5),
    CAST(G AS INT) AS g,
    CAST(GS AS INT) AS gs,
    CAST(f."PERCE" AS DECIMAL(7,2)) AS perce,
    CAST(TS_PER AS DECIMAL(7,3)) AS ts_per,
    CAST(USG_PER AS DECIMAL(7,2)) AS usg_per,
    CAST(WS AS DECIMAL(7,2)) AS ws,
    CAST(BPM AS DECIMAL(7,2)) AS bpm,
    CAST(VORP AS DECIMAL(7,2)) AS vorp,
    CAST(MP AS INT) AS mp,
    CAST(Age AS INT) AS age,
    CAST(Salary AS DECIMAL(12,2)) AS salary
FROM FLOWFILE AS f

-- Clean_salaries Process Group
-- Flow: ListS3 --> FetchS3Object_salaries --> UpdateAttribute --> UpdateRecord --> UpdateRecord -->
-- QueryRecord --> PutS3Object
-- QueryRecord to select all columns from the cleaned salaries file
-- The flow uses - concat(/Player, '_', /Season) - in the UpdateRecord processor to create a unique
-- player_season_key to join the stats and salaries data using join_players.py

SELECT *
FROM FLOWFILE
