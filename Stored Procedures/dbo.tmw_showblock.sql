SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[tmw_showblock]
as
declare @realblock int, @id int, @block int

select @block= 0
Select 	@realblock = min(s1.spid)
FROM
	master..sysprocesses s1, master..sysprocesses s2	
where s1.spid = s2.blocked and s1.blocked = 0
if @realblock > 0
begin	select @block = 1
	select @realblock
	dbcc inputbuffer(@realblock)
end
select @id = min(blocked) from master..sysprocesses
if @id > 0 and @id <> @realblock
begin	select @block = 1
	select @id
	dbcc inputbuffer(@id)
end
select @id = max(blocked) from master..sysprocesses
if @id > 0 and @id <> @realblock
begin	select @block = 1
	select @id
	dbcc inputbuffer(@id)
end

if @block= 0
begin
	select 'No blocking found'
	return
end


Select distinct 
	s1.spid,
	s1.blocked 'block by',
	s1.status, s1.program_name, s1.loginame
FROM
	master..sysprocesses s1, master..sysprocesses s2	
where s1.spid = s2.blocked
order by s1.blocked desc, s1.spid

select req_spid,object_name(rsc_objid) 'object', 
	INDEX_COL(object_name(rsc_objid), rsc_indid, 1) 'index',
	(case when rsc_type = 2 then 'Database'
		when rsc_type = 3 then 'File'
		when rsc_type = 4 then 'Index'
		when rsc_type = 5 then 'Table'
		when rsc_type = 6 then 'Page'
		when rsc_type = 7 then 'Key'
		when rsc_type = 8 then 'Extent'
		when rsc_type = 9 then 'Row ID'
		when rsc_type = 10 then 'Application'
		else '?' end) 'Mode', 
	(case when req_mode = 0 then '0'
	when req_mode in (1, 2) then 'Schema'
	when req_mode = 3 then 'Shared'
	when req_mode = 4 then 'Update'
	when req_mode = 5 then 'Exclusive'
	when req_mode = 6 then 'Intent Shared'
	when req_mode = 7 then 'Intent Update'
	when req_mode = 8 then 'Intent Exclusive'
	when req_mode = 9 then 'Shared Intent Update'
	when req_mode = 10 then 'Shared Intent Exclusive'
	when req_mode = 11 then 'Update Intent Exclusive'
	else convert(varchar(5),req_mode) end) 'type'
	,count(*) 'lock count' 
	from master..syslockinfo
where rsc_dbid = db_id() and rsc_type <> 2
group by
req_spid, object_name(rsc_objid), 
	INDEX_COL(object_name(rsc_objid), rsc_indid, 1),
	
	(case when rsc_type = 2 then 'Database'
		when rsc_type = 3 then 'File'
		when rsc_type = 4 then 'Index'
		when rsc_type = 5 then 'Table'
		when rsc_type = 6 then 'Page'
		when rsc_type = 7 then 'Key'
		when rsc_type = 8 then 'Extent'
		when rsc_type = 9 then 'Row ID'
		when rsc_type = 10 then 'Application'
		else '?' end), 
	(case when req_mode = 0 then '0'
	when req_mode in (1, 2) then 'Schema'
	when req_mode = 3 then 'Shared'
	when req_mode = 4 then 'Update'
	when req_mode = 5 then 'Exclusive'
	when req_mode = 6 then 'Intent Shared'
	when req_mode = 7 then 'Intent Update'
	when req_mode = 8 then 'Intent Exclusive'
	when req_mode = 9 then 'Shared Intent Update'
	when req_mode = 10 then 'Shared Intent Exclusive'
	when req_mode = 11 then 'Update Intent Exclusive'
	else convert(varchar(5),req_mode) end)
order by 1 desc
GO
GRANT EXECUTE ON  [dbo].[tmw_showblock] TO [public]
GO
