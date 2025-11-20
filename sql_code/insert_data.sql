SET search_path TO nba;

-- Took out IAM role for security reasons
COPY dim_season
FROM 's3://data226finalproject/dim_season.csv'
IAM_ROLE 'MY_IAM_ROLE'
REGION 'us-west-1'
FORMAT AS CSV
IGNOREHEADER 1
DELIMITER ','
EMPTYASNULL
BLANKSASNULL
TRUNCATECOLUMNS;

COPY dim_player
FROM 's3://data226finalproject/dim_player.csv'
IAM_ROLE 'MY_IAM_ROLE'
REGION 'us-west-1'
FORMAT AS CSV
IGNOREHEADER 1
DELIMITER ','
EMPTYASNULL
BLANKSASNULL
TRUNCATECOLUMNS;

COPY dim_team
FROM 's3://data226finalproject/dim_team.csv'
IAM_ROLE 'MY_IAM_ROLE'
REGION 'us-west-1'
FORMAT AS CSV
IGNOREHEADER 1
DELIMITER ','
EMPTYASNULL
BLANKSASNULL
TRUNCATECOLUMNS;

COPY fact_player_season (player_key, team_key, season_key, pos, g, gs, perce, ts_per, usg_per,
ws, bpm, vorp, mp, age, salary)
FROM 's3://data226finalproject/fact_player_season.csv'
IAM_ROLE 'MY_IAM_ROLE'
REGION 'us-west-1'
FORMAT AS CSV
IGNOREHEADER 1
DELIMITER ','
EMPTYASNULL
BLANKSASNULL
TRUNCATECOLUMNS;
