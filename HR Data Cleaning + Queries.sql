CREATE DATABASE projects;

USE projects;

SELECT * FROM hr;

ALTER TABLE hr RENAME COLUMN ï»¿id TO id;
ALTER TABLE hr MODIFY COLUMN id VARCHAR(20) NOT NULL;
DESC hr;

SET SQL_SAFE_UPDATES = 0;

UPDATE hr SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr MODIFY COLUMN birthdate DATE;

UPDATE hr SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr MODIFY COLUMN hire_date DATE;

SET sql_mode="NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION";

UPDATE hr SET 
termdate = DATE(str_to_date(termdate,'%Y-%m-%D %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';

ALTER TABLE hr MODIFY COLUMN termdate DATE;

ALTER TABLE hr ADD COLUMN age INT;

UPDATE hr SET age = TIMESTAMPDIFF(YEAR, birthdate, NOW());

SELECT min(age) AS Youngest, max(age) AS Oldest FROM hr;

SELECT count(age) FROM hr WHERE age<18;

-- Gender Breakdown of employees in the company?
SELECT gender, count(*) AS Count FROM hr WHERE age>=18 AND termdate = 0000-00-00 GROUP BY gender;

-- Race/Ethnicity Breakdown of employees in the company?
SELECT race, count(*) AS Count FROM hr WHERE age>=18 AND termdate = 0000-00-00 GROUP BY race ORDER BY count DESC;

-- Age Distribution of employees in the company
SELECT min(age) AS Youngest, max(age) AS Oldest FROM hr WHERE age>=18 AND termdate = 0000-00-00;

SELECT CASE
	WHEN age >=18 AND age <= 24 THEN '18-24'
	WHEN age >=25 AND age <= 34 THEN '25-34'
    WHEN age >=35 AND age <= 44 THEN '35-44'
    WHEN age >=45 AND age <= 54 THEN '45-54'
    WHEN age >=55 AND age <= 64 THEN '55-64'
    ELSE '65+'
END AS age_group, 
count(*) AS Count FROM hr WHERE age>=18 AND termdate = 0000-00-00 GROUP BY age_group ORDER BY age_group;

SELECT CASE
	WHEN age >=18 AND age <= 24 THEN '18-24'
	WHEN age >=25 AND age <= 34 THEN '25-34'
    WHEN age >=35 AND age <= 44 THEN '35-44'
    WHEN age >=45 AND age <= 54 THEN '45-54'
    WHEN age >=55 AND age <= 64 THEN '55-64'
    ELSE '65+'
END AS age_group, gender,
count(*) AS Count FROM hr WHERE age>=18 AND termdate = 0000-00-00 GROUP BY age_group,gender ORDER BY age_group, gender;

-- Employees work at Headquarters vs Remote Locations
SELECT location, count(*) AS Count FROM hr WHERE age>=18 AND termdate = 0000-00-00 GROUP BY location;

-- The Average length of employment for employees who have been terminated
SELECT round(avg(datediff(termdate, hire_date))/365,0) AS avg_length_employment FROM hr WHERE termdate<=curdate() AND termdate <> 0000-00-00 AND age>=18;

-- Gender distribution vary across departments and job titles
SELECT department, gender, count(*) AS Count FROM hr WHERE age>=18 AND termdate = 0000-00-00 GROUP BY department, gender ORDER BY department;

-- Distribution of job titles across the company
SELECT jobtitle, count(*) AS Count FROM hr WHERE age>=18 AND termdate = 0000-00-00 GROUP BY jobtitle ORDER BY jobtitle DESC;

-- Department which has highest turnover rate
SELECT department, total_count, terminated_count, terminated_count/total_count AS termination_rate FROM (
	SELECT department, count(*) AS total_count,
    sum(CASE WHEN termdate <> 0000-00-00 AND termdate<= curdate()THEN 1 ELSE 0 END) AS terminated_count
    FROM hr WHERE age >= 18 GROUP BY department)
    AS subquery ORDER BY termination_rate DESC;

-- Distribution of employees across locations by city and state 
SELECT location_state, count(*) AS Count FROM hr WHERE age>=18 AND termdate = 0000-00-00 GROUP BY location_state ORDER BY Count DESC;

-- Company's employee count changed changed over time based on hire and term dates
SELECT year, hires, terminations, (hires - terminations) AS net_change, round((hires - terminations)/hires * 100, 2) AS net_change_percent FROM
	(SELECT year(hire_date) AS year, 
		count(*) AS hires,
        sum(CASE WHEN termdate <> 0000-00-00 AND termdate<= curdate()THEN 1 ELSE 0 END) AS terminations
        FROM hr GROUP BY year) AS subquery
        ORDER BY hires;
        
-- Tenure distribution for each department
SELECT department, round(avg(datediff(termdate, hire_date))/365,0) AS Average_tenure FROM hr WHERE termdate <> 0000-00-00 AND termdate<= curdate() AND age >= 18
    GROUP BY department;

