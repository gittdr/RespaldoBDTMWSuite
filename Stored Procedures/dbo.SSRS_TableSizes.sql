SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[SSRS_TableSizes]
(
	@MinRows int,
	@MinReservedKB float,
	@MinDataKB float,
	@MinIndexSizeKB float,
	@UnusedKB float,
	@MinReservedGB float
)
						
AS

SET NOCOUNT ON

/**
 *
 * NAME:
 * dbo.SSRS_TableSizes
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Size of tables
 *
**************************************************************************

Sample call

exec [SSRS_TableSizes] 


**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 *Table Sizes
 *
 * PARAMETERS:
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 5/08/2014 JR created Based on DBA script
 **/

--POINT THIS AT THE TMW DB
set nocount on 
declare @id	int			
declare @type	character(2) 		
declare	@pages	int			
declare @dbname sysname
declare @dbsize dec(15,0)
declare @bytesperpage	dec(15,0)
declare @pagesperMB		dec(15,0)

create table #spt_space
(
	objid		int null,
	rows		int null,
	reserved	dec(15) null,
	data		dec(15) null,
	indexp		dec(15) null,
	unused		dec(15) null
)

set nocount on

-- Create a cursor to loop through the user tables
declare c_tables cursor for
select	id
from	sysobjects
where	xtype = 'U'

open c_tables

fetch next from c_tables
into @id

while @@fetch_status = 0
begin

	/* Code from sp_spaceused */
	insert into #spt_space (objid, reserved)
		select objid = @id, sum(reserved)
			from sysindexes
				where indid in (0, 1, 255)
					and id = @id

	select @pages = sum(dpages)
			from sysindexes
				where indid < 2
					and id = @id
	select @pages = @pages + isnull(sum(used), 0)
		from sysindexes
			where indid = 255
				and id = @id
	update #spt_space
		set data = @pages
	where objid = @id


	/* index: sum(used) where indid in (0, 1, 255) - data */
	update #spt_space
		set indexp = (select sum(used)
				from sysindexes
				where indid in (0, 1, 255)
				and id = @id)
			    - data
		where objid = @id

	/* unused: sum(reserved) - sum(used) where indid in (0, 1, 255) */
	update #spt_space
		set unused = reserved
				- (select sum(used)
					from sysindexes
						where indid in (0, 1, 255)
						and id = @id)
		where objid = @id

	update #spt_space
		set rows = i.rows
			from sysindexes i
				where i.indid < 2
				and i.id = @id
				and objid = @id

	fetch next from c_tables
	into @id
end

select 	--top 10 
    db_name() as DbName,
    TableName = (select left(name,60) from sysobjects where id = objid),
	Rows = rows,
	ReservedKB = reserved * d.low / 1024.,
	DataKB = data * d.low / 1024.,
	IndexSizeKB = indexp * d.low / 1024.,
	UnusedKB = unused * d.low / 1024.,
    ReservedGB = reserved * d.low / POWER(1024.,3)
into #tempresults		
from 	#spt_space, master.dbo.spt_values d
where 	d.number = 1
and 	d.type = 'E'
order by reserved desc 

select *
from #tempresults
where
	 Rows >= @MinRows 
	and ReservedKB >= @MinReservedKB
	and DataKB >= @MinDataKB
	and IndexSizeKB >= @MinIndexSizeKB
	and UnusedKB >= @UnusedKB
	and ReservedGB >= @MinReservedGB 

drop table #spt_space
close c_tables
deallocate c_tables

GO
GRANT EXECUTE ON  [dbo].[SSRS_TableSizes] TO [public]
GO
