use employees;

 -- Task 1 (Joins) --
 -- Select all managers’ first and last name, hire date, job title, start date, and department name -- 
 SELECT
    e.first_name,
    e.last_name,
    e.hire_date,
    t.title,
    m.from_date,
    d.dept_name
FROM
    employees e
        JOIN
    dept_manager m ON e.emp_no = m.emp_no
        JOIN
    departments d ON m.dept_no = d.dept_no
        JOIN
    titles t ON e.emp_no = t.emp_no
WHERE t.title = 'Manager'
ORDER BY e.emp_no;

-- Task 2 (Subqueries) --
-- Extract the information about all department managers who were hired between the 1st of January 1990 and the 1st of January 1995. --
SELECT
    *
FROM
    dept_manager
WHERE
    emp_no IN (SELECT
            emp_no
        FROM
            employees
        WHERE
            hire_date BETWEEN '1990-01-01' AND '1995-01-01');
            
-- Task 3 (Views) --
-- Create a view that will extract the average salary of all managers registered in the database. Round this value to the nearest cent. --
CREATE OR REPLACE VIEW v_manager_avg_salary AS
    SELECT
        ROUND(AVG(salary), 2)
    FROM
        salaries s
            JOIN
        dept_manager m ON s.emp_no = m.emp_no;
        
-- Task 4 (Stored routines) --
-- Create a procedure that will provide the average salary of all employees. --
DELIMITER $$

CREATE PROCEDURE avg_salary()
BEGIN
                SELECT

                                AVG(salary)
                FROM
                                salaries;
END$$
DELIMITER ;



-- Task 5 (Triggers) --
-- Create a trigger that checks if the hire date of an employee is higher than the current date.--
-- If true, set this date to be the current date. Format the output appropriately (YY-MM-DD). -- 

DELIMITER $$
CREATE TRIGGER trig_hire_date  
BEFORE INSERT ON employees
FOR EACH ROW  
BEGIN  
                IF NEW.hire_date > date_format(sysdate(), '%Y-%m-%d') THEN     
                                SET NEW.hire_date = date_format(sysdate(), '%Y-%m-%d');     
                END IF;  
END $$  
DELIMITER ;  


-- Task 6.1 (Window Functions) --
-- Write a query containing a window function to obtain all salary values that employee number 10560 has ever signed a contract for. --
-- Order and display the obtained salary values from highest to lowest. --

SELECT
	emp_no,
	salary,
	ROW_NUMBER() OVER w AS row_num
FROM
	salaries
WHERE emp_no = 10560
WINDOW w AS (PARTITION BY emp_no ORDER BY salary DESC);

-- 6.2 --
 -- Order and rank all contract salary values of employee 10002 from highest to lowest. --
 select
    s.emp_no,
    s.salary,
    rank() over w as order_num
from
    salaries s 
where s.emp_no = 10002
window w as (partition by s.emp_no order by s.salary desc);

-- Task 7.1 (CTEs) --
-- Find out how many male employees have never signed a contract with a salary value higher than or equal to the all-time company salary average. --
WITH cte AS (
SELECT AVG(salary) AS avg_salary FROM salaries
)
SELECT
SUM(CASE WHEN s.salary < c.avg_salary THEN 1 ELSE 0 END) AS no_salaries_below_avg,
COUNT(s.salary) AS no_of_salary_contracts
FROM salaries s JOIN employees e ON s.emp_no = e.emp_no AND e.gender = 'M' JOIN cte c;
        
-- 7.2 --
-- Obtain the number of male employees whose highest salaries have been below the all-time average. --
WITH cte_avg_salary AS (
SELECT AVG(salary) AS avg_salary FROM salaries
),
cte_m_highest_salary AS (
SELECT s.emp_no, MAX(s.salary) AS max_salary
FROM salaries s JOIN employees e ON e.emp_no = s.emp_no AND e.gender = 'M'
GROUP BY s.emp_no
)
SELECT
COUNT(CASE WHEN c2.max_salary < c1.avg_salary THEN c2.max_salary ELSE NULL END) AS max_salary
FROM employees e
JOIN cte_m_highest_salary c2 ON c2.emp_no = e.emp_no

JOIN cte_avg_salary c1;


        
        
        

