SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[purge_audit] @days int
as
/**
 * 
 * NAME:
 * dbo.purge_audit 
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


/*if no record exists default setting to log trips*/
if (select count(*) from generalinfo
	where gi_name = 'TRIPAUDIT') = 0
	insert generalinfo (gi_name, gi_string1)
     	values ('TRIPAUDIT', 'YES') 

delete tripaudit
where upd_date < dateadd(dd, - @days, getdate())

GO
GRANT EXECUTE ON  [dbo].[purge_audit] TO [public]
GO
