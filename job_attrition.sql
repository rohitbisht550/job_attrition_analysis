select * from employee_attrition
limit 20

-- Q1 Show total no. of employees who have worked more than or equal to 6 years in the company.
select count(employee_id) as employees from employee_attrition
where years_at_company >=6

-- Q2 Find the number of employees in each department.
select department,count(*) from employee_attrition
group by department;

--Q3 Find the average monthly income by department.
select department,round(avg(monthly_income),2) as averagesalary from employee_attrition
group by department;

--Q4 Find the top 3 highest-paid employees and their experience_level in each department.
with cte as 
(select department,employee_id,monthly_income,experience_level,
dense_rank()over
(partition by department order by monthly_income desc) as rnk
 from employee_attrition)
select department,employee_id,monthly_income,experience_level from cte
where rnk <=3;

-- Q5 Find the count of employees doing overtime vs not doing overtime.
select count(*) as total_employees, overtime from employee_attrition
group by overtime;

-- Q6 Find the department with the highest attrition count.
select department,count(attrition) as attrition_count from employee_attrition
where attrition = 'Yes'
group by department
order by  attrition_count desc
limit 1;

-- Q7 Find the attrition rate (%) per department(attrition rate = 100 * attrition yes / total employees)
select department, round( 100.0 * sum(
case
when attrition = 'Yes' then 1 else 0 end )/count(*),2) as attrition_rate
from employee_attrition
group by department;

-- Q8 Find whether overtime employees have higher attrition than non-overtime employees.
select overtime,round(count(*) filter (where attrition = 'Yes')*100.0/count(*),2) as attrition_rate
from employee_attrition
group by overtime;

-- Q9 Find the attrition rate according to their experience in company
select case
when  years_at_company <= 2 then '0–2 Years'
when years_at_company between 3 and 5 then '3–5 Years'
when years_at_company between 6 and 10 then'6–10 Years'
else '10+ Years'
end as experience_bucket,
round(count(*) filter (where attrition = 'Yes')*100.0/count(*),2) as attrition_rate
from employee_attrition
group by experience_bucket
order by attrition_rate DESC;

-- Q10 Find the attrition rate of employees earning below department average 
with salary_cte as (
select employee_id,department,attrition,monthly_income,
avg(monthly_income) over (partiton department) as dept_avg_income
from employee_attrition)
selectdepartment,
count(*) filter (wher attrition = 'Yes') * 100.0 / COUNT(*) 
        AS attrition_rate_below_avg
FROM salary_cte
WHERE monthly_income < dept_avg_income
GROUP BY department
ORDER BY attrition_rate_below_avg DESC;

