This is the same question as problem #8 in the SQL Chapter of Ace the Data Science Interview!

Assume you are given the table below that shows job postings for all companies on the LinkedIn platform. Write a query to get the number of companies that have posted duplicate job listings.

Clarification:

Duplicate job listings refer to two jobs at the same company with the same title and description.



![image](https://user-images.githubusercontent.com/85264359/212795321-84ac32d4-1763-473f-a74c-907fb7fbdf6b.png)

WITH CTE

SELECT COUNT(DISTINCT company_id) AS co_w_duplicate_jobs
FROM (
  SELECT 
    company_id, 
    title, 
    description, 
    COUNT(job_id) AS job_count
  FROM job_listings
  GROUP BY 
    company_id, 
    title, 
    description) AS jobs_grouped
WHERE job_count > 1;

.
.
.
.
.




WITH SUBQUERY

WITH jobs_grouped AS (
  SELECT 
    company_id, 
    title, 
    description, 
    COUNT(job_id) AS job_count
  FROM job_listings
  GROUP BY 
    company_id, 
    title, 
    description)

SELECT COUNT(DISTINCT company_id) AS co_w_duplicate_jobs
FROM jobs_grouped
WHERE job_count > 1;

