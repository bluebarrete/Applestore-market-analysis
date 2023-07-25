create table appleStore_description_combined AS

SELECT * FROM appleStore_description1

UNION ALL

select * from appleStore_description2

union all 

select * from appleStore_description3

union ALL

select * from appleStore_description4


** EXPLORATORY  DATA ANALYSIS **
-- check the number of unique apps in both tablesAppleStore 

select count (distinct id) as uniqueappids
from AppleStore

select count (distinct id) as uniqueappids
from appleStore_description_combined

--check for missing values in key fields--
select count (*)
from AppleStore
WHERE track_name is null or user_rating is null OR prime_genre is NULL

select count (*)
from appleStore_description_combined
WHERE app_desc is NULL

--find out the number of apps per genre--
select prime_genre, count(*) AS numapps
from AppleStore
group BY prime_genre
order by numapps DESC

--get an overview of the app ratings--
select min(user_rating) as minrating,
	   max(user_rating) as maxrating,
       avg(user_rating) as avgrating
from AppleStore



**DATA ANALYSIS**

--1.Determine wether paid apps have a higher rating than free apps--
select case
			when price > 0 then 'paid'
            else 'free'
       end as App_type,
       avg(user_rating) as avg_rating
from AppleStore
group by App_type

--(rating of paid apps is slightly higher than free apps)--

-- 2. Do apps that support more languaes get hiher rating?--

SELECT CASE 
			when lang_num < 10 THEN 'less than 10'
            when lang_num BETWEEN 10 AND 30 then '10-30 languages' 
            ELSE '>30 languages'
      end as language_pool,
      avg(user_rating) as Avg_Rating
from AppleStore
GROUP by language_pool
order by Avg_Rating DESC

--( we can see 10-30 languages are suffienct enough to get good ratings)--


--3. check genres  with low ratings--

select prime_genre, avg(user_rating) as Avg_Rating
from AppleStore
GROUP by prime_genre
ORDER by Avg_Rating ASC
limit 15

--(there is space to create apps in. catalogs and finance industry)-- 


--4. is there a correlation between length of app description and use ratings--
SELECT case 
			when length(app_desc) <500 then 'Short description'
            when length(app_desc) BETWEEN 500 and 1000 THEN 'Medium description'
            ELSE 'long description'
    end as description_length_bucket,
    avg(a.user_rating) as avg_rating
    
 from AppleStore as a 
 
 join appleStore_description_combined as b 
 
 on  a.id = b.id
 
 GROUP by description_length_bucket
 order by avg_rating DESC
 
 --(we can discern that the longer the descripitiopn the better the rating)--
 
 

--5. check the top rated apps for a each genre--

select 
		prime_genre, track_name,user_rating
FROM(
  		SELECT
  		prime_genre,track_name,user_rating,
  		RANK() OVER(PARTITION BY prime_genre ORDER by user_rating DESC, rating_count_tot DESC) AS rank
  		FROM AppleStore
  	) AS a	

WHERE
a.rank =1 
 
