select * from COUNTRY

select * from INFORMATION_ScHEMA.table_CONSTRAINTS

select constraint_name, table_name, constraint_type  from INFORMATION_ScHEMA.table_CONSTRAINTS 
where constraint_type = 'PRIMARY KEY'

select constraint_name, table_name, constraint_type  from INFORMATION_ScHEMA.table_CONSTRAINTS 
where constraint_type = 'PRIMARY KEY' 
and table_schema = 'public'