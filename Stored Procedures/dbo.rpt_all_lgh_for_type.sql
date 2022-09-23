SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[rpt_all_lgh_for_type] @type varchar(6) as
/**
 * 
 * NAME:
 * dbo.rpt_all_lgh_for_type 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001 -   
 * Calls002 -
 *
 * CalledBy001 -
 * CalledBy002 - 
 *
 * REVISION HISTORY:
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 *
 **/


/* create temporary table */
create table #t
	(assetid varchar(13) not null,
	lgh_number int not null)



select @type = upper(@type)

if (@type ='DRV') 
begin
	insert #t
	(assetid, lgh_number)
	select mpp_id, 0
	from manpowerprofile
	where mpp_id <> 'UNKNOWN' and mpp_status <>'OUT'
end

if (@type ='TRC') 
begin
	insert #t
	(assetid, lgh_number)
	select trc_number, 0
	from tractorprofile
	where trc_number <> 'UNKNOWN' and trc_status <>'OUT'
end
if (@type ='TRL') 
begin
	insert #t
	(assetid, lgh_number)
	select trl_id, 0
	from trailerprofile
	where trl_id <> 'UNKNOWN' and trl_status <>'OUT'
end

declare   @id 	 varchar(13), 
	  @lgh   int


select @id=''


while (select count(*) from #t
	where assetid > @id) > 0
begin
	select @id = min(assetid)
	from #t
	where assetid > @id
	select @lgh = 0
	exec cur_activity  @type, @id, @lgh OUT 

	update #t
	set lgh_number = @lgh
	where assetid = @id
end 

select * from #t where assetid <> 'UNKNOWN'

drop table #t
GO
GRANT EXECUTE ON  [dbo].[rpt_all_lgh_for_type] TO [public]
GO
