--Q1. Management wants to see all the users that have not loggedin in last 5 months. (Assume current date as 2024-06-28)

select u.USER_NAME, l.USER_ID,max(LOGIN_TIMESTAMP) 
from logins l join users u
on l.USER_ID=u.USER_ID
group by USER_ID
having max(LOGIN_TIMESTAMP)< DATE_SUB('2024-06-28', INTERVAL 5 MONTH)

--Q2 For the business quaterly analysis, calculate how many users and how many sessions were there at each quarter & order 
--them by quarter from newest to oldest.
-- Return 1st day of quarter, user_cnt, session_cnt

select date_format(date_sub(login_timestamp, interval(month(login_timestamp)-1)%3 month),'%Y-%m-01') as q_start,
count(distinct user_id) as user_cnt, count(session_id) as session_cnt
from logins
group by q_start
order by q_start desc

--Q3 Display user id that loggedin on Jan 2024 and didnt login on Nov 2023.
select distinct user_id
from logins
where (login_timestamp between '2024-01-01' and '2024-01-31') and user_id not in(
select distinct user_id
from logins
where login_timestamp between '2023-11-01' and '2023-11-30')


--Q4. Add to the query from Q2 and calculate the % change in session count from last quarter.
select date_format(date_sub(login_timestamp, interval(month(login_timestamp)-1)%3 month),'%Y-%m-01') as quarter_start,
count(distinct user_id) as user_cnt,count(session_id) as session_cnt,
lag(count(session_id)) over(order by  date_format(date_sub(login_timestamp, interval(month(login_timestamp)-1)%3 month),'%Y-%m-01') ) as prev_session_cnt,
(count(session_id)-lag(count(session_id)) over(order by  date_format(date_sub(login_timestamp, interval(month(login_timestamp)-1)%3 month),'%Y-%m-01')))/count(session_id)*100 as percent_chng
 from logins
 group by quarter_start
 order by quarter_start
 
 --Q5. Display the user with highest session score for each day.
select * from(
select *, row_number() over(partition by date_format(login_timestamp,'%Y-%m-%d') order by session_score desc) as rown
from logins
) as s
where rown=1


--Q6. Select the best user id i.e Return the users that have each session on every single day since their 1st session
--make assumption if needed.

select user_id, min(cast(login_timestamp as date)),count(distinct(cast(login_timestamp as date))),
datediff('2024-06-28',min(cast(login_timestamp as date)))+1
from logins
group by user_id
having count(distinct(cast(login_timestamp as date)))=datediff('2024-06-28',min(cast(login_timestamp as date)))+1

--Q7. On number of days where there were no login at all
select datediff(max(login_timestamp),min(login_timestamp))-count(distinct(login_timestamp)) from logins
