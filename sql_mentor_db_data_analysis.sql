create table user_submissions(
	id serial primary key,
	user_id bigint,
	question_id int,
	points int,
	submitted_at timestamp with time zone,
	username varchar(50)
);

select * from user_submissions

-- Q1. List all distinct users and their stats (return user_name, total_submissions, points earned).
select username,count(*) as total_submissions,sum(points) as points_earned 
from user_submissions
group by username 

-- Q2. Calculate the daily average points for each user.
select username, round(avg(points),2), TO_CHAR(submitted_at,'dd-mm-yyyy') as days 
from user_submissions as avg_daily_points
group by days, username, submitted_at::date
ORDER BY username, submitted_at::date;

-- Q3. Find the top 3 users with the most positive submissions for each day.
WITH daily_counts AS (
    SELECT
        submitted_at::date AS day,
        username,
        COUNT(*) AS positive_submissions
    FROM user_submissions
    WHERE points > 0
    GROUP BY submitted_at::date, username
),
ranked AS (
    SELECT
        day,
        username,
        positive_submissions,
        DENSE_RANK() OVER (
            PARTITION BY day
            ORDER BY positive_submissions DESC
        ) AS rnk
    FROM daily_counts
)
SELECT
    TO_CHAR(day, 'DD-MM-YYYY') AS days,
    username,
    positive_submissions,
    rnk
FROM ranked
WHERE rnk <= 3
ORDER BY day, rnk, username;

-- Q4. Find the top 5 users with the highest number of incorrect submissions.
WITH daily_counts AS (
    SELECT
        submitted_at::date AS day,
        username,
        COUNT(*) AS positive_submissions
    FROM user_submissions
    WHERE points < 0
    GROUP BY submitted_at::date, username
),
ranked AS (
    SELECT
        day,
        username,
        positive_submissions,
        DENSE_RANK() OVER (
            PARTITION BY day
            ORDER BY positive_submissions DESC
        ) AS rnk
    FROM daily_counts
)
SELECT
    TO_CHAR(day, 'DD-MM-YYYY') AS days,
    username,
    positive_submissions,
    rnk
FROM ranked
WHERE rnk <= 5
ORDER BY day, rnk, username;

-- Q5. Find the top 10 performers for each week.
WITH weekly_points AS (
    SELECT
        DATE_TRUNC('week', submitted_at)::date AS week_start,
        username,
        SUM(points) AS total_points
    FROM user_submissions
    GROUP BY DATE_TRUNC('week', submitted_at)::date, username
),
ranked AS (
    SELECT
        week_start,
        username,
        total_points,
        DENSE_RANK() OVER (
            PARTITION BY week_start
            ORDER BY total_points DESC
        ) AS rnk
    FROM weekly_points
)
SELECT
    week_start,
    username,
    total_points,
    rnk
FROM ranked
WHERE rnk <= 10
ORDER BY week_start, rnk, username;