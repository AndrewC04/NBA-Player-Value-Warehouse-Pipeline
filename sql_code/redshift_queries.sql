-- Direct Redshift Query to list all player stats and names who meet the threshold of at least 750 minutes played
-- Saved as everything_final.csv to power the dashboard
SELECT
    f.player_key,
    p.full_name,
    f.team_key,
    f.season_key,
    f.g, f.gs,
    f.perce,
    f.ts_per,
    f.usg_per,
    f.ws,
    f.bpm,
    f.vorp,
    f.mp,
    f.age,
    f.salary,
    f.value,
    f.deserved_salary,
    f.salary_gap,
    f.overpaid_underpaid,
    f.fair_value
FROM fact_player_season AS f
JOIN dim_player AS p ON p.player_key = f.player_key
WHERE f.mp >= 750;

-- Top 10 overpaid players with largest salary gap
SELECT DISTINCT p.full_name AS player,
CASE 
    WHEN f.salary_gap < 0 THEN 
        '-' || '$' || TO_CHAR(ABS(f.salary_gap) / 1000000, 'FM999,990.00') || ' million'
    ELSE 
        '$' || TO_CHAR(f.salary_gap / 1000000, 'FM999,990.00') || ' million'
END AS salary_gap_millions,
f.season_key AS season, f.team_key AS team
FROM fact_player_season AS f
JOIN dim_player AS p  ON p.player_key = f.player_key
WHERE f.overpaid_underpaid > 0
AND f.mp >= 750
AND f.team_key NOT LIKE '%TM%'
ORDER BY f.salary_gap ASC
LIMIT 10;

-- Top 10 underpaid players with largest salary gap
SELECT DISTINCT p.full_name AS player,
CASE 
    WHEN f.salary_gap < 0 THEN 
        '-' || '$' || TO_CHAR(ABS(f.salary_gap) / 1000000, 'FM999,990.00') || ' million'
    ELSE 
        '$' || TO_CHAR(f.salary_gap / 1000000, 'FM999,990.00') || ' million'
END AS salary_gap_millions,
f.season_key AS season, f.team_key AS team
FROM fact_player_season AS f
JOIN dim_player AS p  ON p.player_key = f.player_key
WHERE f.overpaid_underpaid < 0
AND f.mp >= 750
AND f.team_key NOT LIKE '%TM%'
ORDER BY f.salary_gap DESC
LIMIT 10;

-- Team counts of overpaid/underpaid
WITH overpaid AS (
    SELECT team_key, COUNT(*) AS oc
    FROM fact_player_season
    WHERE overpaid_underpaid > 0
    AND mp >= 750
    AND team_key NOT LIKE '%TM%'
    GROUP BY team_key
),
underpaid AS (
    SELECT team_key, COUNT(*) AS uc
    FROM fact_player_season
    WHERE overpaid_underpaid < 0
    AND mp >= 750
    AND team_key NOT LIKE '%TM%'
    GROUP BY team_key
)
SELECT
    COALESCE(o.team_key, u.team_key) AS team,
    COALESCE(u.uc, 0) AS underpaid,
    COALESCE(o.oc, 0) AS overpaid
FROM underpaid AS u
FULL JOIN overpaid AS o ON o.team_key = u.team_key
ORDER BY team ASC;

-- Season count of overpaid/underpaid
WITH overpaid AS (
    SELECT season_key, COUNT(*) AS oc
    FROM fact_player_season
    WHERE overpaid_underpaid > 0 AND mp >= 750
    GROUP BY season_key
),
underpaid AS (
    SELECT season_key, COUNT(*) AS uc
    FROM fact_player_season
    WHERE overpaid_underpaid < 0 AND mp >= 750
    GROUP BY season_key
)
SELECT
    COALESCE(o.season_key, u.season_key) AS season_key,
    COALESCE(u.uc, 0) AS underpaid,
    COALESCE(o.oc, 0) AS overpaid
FROM underpaid AS u
FULL JOIN overpaid AS o ON o.season_key = u.season_key
ORDER BY season_key ASC;

-- Comparison of average deserved salary vs average salary gap by age
SELECT age,
CASE
    WHEN AVG(deserved_salary) < 0 THEN 
        '-' || '$' || TO_CHAR(ABS(AVG(deserved_salary)) / 1000000, 'FM999,990.00') || ' million'
    ELSE 
        '$' || TO_CHAR(AVG(deserved_salary) / 1000000, 'FM999,990.00') || ' million'
END AS avg_value_millions,
CASE 
    WHEN AVG(salary_gap) < 0 THEN 
        '-' || '$' || TO_CHAR(ABS(AVG(salary_gap)) / 1000000, 'FM999,990.00') || ' million'
    ELSE 
        '$' || TO_CHAR(AVG(salary_gap) / 1000000, 'FM999,990.00') || ' million'
END AS avg_salary_gap_millions
FROM fact_player_season
GROUP BY age
ORDER BY age;

-- Comparison of average deserved salary vs average salary gap by position and season
SELECT pos AS position, season_key as season,
CASE
    WHEN AVG(deserved_salary) < 0 THEN 
        '-' || '$' || TO_CHAR(ABS(AVG(deserved_salary)) / 1000000, 'FM999,990.00') || ' million'
    ELSE 
        '$' || TO_CHAR(AVG(deserved_salary) / 1000000, 'FM999,990.00') || ' million'
END AS avg_value_millions,
CASE 
    WHEN AVG(salary_gap) < 0 THEN 
        '-' || '$' || TO_CHAR(ABS(AVG(salary_gap)) / 1000000, 'FM999,990.00') || ' million'
    ELSE 
        '$' || TO_CHAR(AVG(salary_gap) / 1000000, 'FM999,990.00') || ' million'
END AS avg_salary_gap_millions
FROM fact_player_season
GROUP BY pos, season_key
ORDER BY pos, season_key;

-- Comparison of average deserved salary vs average salary gap by position
SELECT pos AS position,
CASE
    WHEN AVG(deserved_salary) < 0 THEN 
        '-' || '$' || TO_CHAR(ABS(AVG(deserved_salary)) / 1000000, 'FM999,990.00') || ' million'
    ELSE 
        '$' || TO_CHAR(AVG(deserved_salary) / 1000000, 'FM999,990.00') || ' million'
END AS avg_value_millions,
CASE 
    WHEN AVG(salary_gap) < 0 THEN 
        '-' || '$' || TO_CHAR(ABS(AVG(salary_gap)) / 1000000, 'FM999,990.00') || ' million'
    ELSE 
        '$' || TO_CHAR(AVG(salary_gap) / 1000000, 'FM999,990.00') || ' million'
END AS avg_salary_gap_millions
FROM fact_player_season
GROUP BY pos
ORDER BY pos;

-- Comparison of average deserved salary vs average salary gap by season
SELECT season_key AS season,
CASE
    WHEN AVG(deserved_salary) < 0 THEN 
        '-' || '$' || TO_CHAR(ABS(AVG(deserved_salary)) / 1000000, 'FM999,990.00') || ' million'
    ELSE 
        '$' || TO_CHAR(AVG(deserved_salary) / 1000000, 'FM999,990.00') || ' million'
END AS avg_value_millions,
CASE 
    WHEN AVG(salary_gap) < 0 THEN 
        '-' || '$' || TO_CHAR(ABS(AVG(salary_gap)) / 1000000, 'FM999,990.00') || ' million'
    ELSE 
        '$' || TO_CHAR(AVG(salary_gap) / 1000000, 'FM999,990.00') || ' million'
END AS avg_salary_gap_millions
FROM fact_player_season
GROUP BY season
ORDER BY season;
