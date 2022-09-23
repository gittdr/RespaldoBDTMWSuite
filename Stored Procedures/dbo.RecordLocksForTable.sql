SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

Create Proc [dbo].[RecordLocksForTable] @p_table varchar(100)
As
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
	SR 52585 DPETE created to use dot net record locking table for Invoice queus locking
 *
 **/
 declare @v_now datetime
 select @v_now = getdate()

select rlt_table
,rlt_tablekey
,rlt_userID
,rlt_workstation
,rlt_sessionID
,rlt_applicationID
,rlt_locktime
,rlt_lockexpires
,rlt_instanceID
,minuteslocked = datediff(mi,rlt_locktime,@v_now)
from recordlockingtable
where rlt_table = @p_table


GO
GRANT EXECUTE ON  [dbo].[RecordLocksForTable] TO [public]
GO
