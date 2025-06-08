select *
from employee e 

select *
from employee_salary es


select sum(salary)
from (
select *,
last_value (effective_from) over (partition by emp_id)
from (
select *
from employee_salary
order by emp_id, effective_from desc))
where effective_from=last_value


select sum(es.salary)
from employee_salary es
where (es.emp_id, es.effective_from) in (
	select emp_id, max(effective_from)
	from employee_salary
	group by emp_id)
	
	
	
	
select es.emp_id, es.salary, string_agg(g.grade::text, ' ') 
from employee_salary es 
left join grade_salary g on es.salary between g.min_salary and g.max_salary
where (es.emp_id, es.effective_from) in (
	select emp_id, max(effective_from)
	from employee_salary
	group by 1)
group by es.emp_id, es.salary
--в виде строки вывести зарплатные грейды в которые попадают текущие оклады сотрудников.

select *
from employee_salary es

	
select *
from employee e 

select *
from grade_salary gs 




