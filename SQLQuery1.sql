create database Sql_Mentor
use Sql_mentor
--------------- user_submissions ------------------------
drop table if exists user_submissions
create table user_submissions(
id int,
user_id bigint,
question_id int,
points int,
submitted_at datetimeoffset,
username varchar(50)
)
select *
from user_submissions
-- bulk insert
bulk insert user_submissions
from 'C:\Users\srava\Desktop\excel csv files\user_sub_sql_mentor06nov.csv'
with(fieldterminator= ',',rowterminator= '\n',firstrow= 2)

select *
from user_submissions

-- Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)
select username,COUNT(submitted_at) as total_submissions,SUM(points) as points_earned
from user_submissions
group by username
order by total_submissions desc

-- Q.2 Calculate the daily average points for each user.
select username,cast(submitted_at as date) as submission_date,AVG(points) as Average_points
from user_submissions
group by username,cast(submitted_at as date)
order by username
    ---------------------------------------
with cte as
(select username,CAST(submitted_at as date) as submission_date,SUM(points) as total_points
from user_submissions
group by username,CAST(submitted_at as date)
)
select username,AVG(total_points) as average_points
from cte
group by username

-- Q.3 Find the top 3 users with the most positive submissions for each day.
with cte as
(select CAST(submitted_at as date) as submitted_date,username,sum(case when points >0 then 1 else 0 end) as correct_submission
from user_submissions
group by CAST(submitted_at as date),username
),
cte2 as
(select submitted_date,username,correct_submission,DENSE_RANK() over(partition by submitted_date order by correct_submission desc) as dr
from cte
)
select submitted_date,username,correct_submission
from cte2
where dr <=3

-- Q.4 Find the top 5 users with the highest number of incorrect submissions.
with cte as
(select username,sum(case when points <0 then 1 else 0 end) as incorrect_submission,DENSE_RANK() over(order by sum(case when points <0 then 1 else 0 end) desc) as dr
from user_submissions
group by username
)
select username
from cte
where dr <=5
 --------- or ------------
select top 5 username,sum(case when points <0 then 1 else 0 end) as incorrect_submission,SUM(case when points <0 then points else 0 end) as incorrect_points_score,
SUM(case when points >0 then 1 else 0 end) as correct_submission,SUM(case when points >0 then points else 0 end) as correct_points_score,SUM(points) as total_score
from user_submissions
group by username
order by incorrect_submission desc

-- Q.5 Find the top 10 performers for each week.
select *
from user_submissions

with cte as
(select DATEPART(week,CAST(submitted_at as date)) as weeks,username,SUM(points) as total_score,
DENSE_RANK() over(partition by DATEPART(week,CAST(submitted_at as date)) order by SUM(points) desc) as dr
from user_submissions
group by username,DATEPART(week,CAST(submitted_at as date))
)
select weeks,username,total_score,dr
from cte
where dr <= 10

