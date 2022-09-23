SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create procedure [dbo].[AddRecordLockingTableLock] @p_table varchar(25),@p_tablekey varchar(9),@p_appid varchar(128),@P_LockObtained char(1) OUTPUT,
   @p_Lockobtainedby varchar(128) OUTPUT,@p_lockobtainedforAppID varchar(128) OUTPUT, @p_minuteslocked int OUTPUT
  

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
	SR 52585 DPETE created to use dot net record locking table for Invoice queues locking
              7/22 getting a problem when string3 is set to -1
 *
 **/
 Declare @tmwuser varchar(128),@now datetime, @expires datetime, @temp varchar(100),@expiremins int
 exec gettmwuser @tmwuser output
 
 select @now = getdate()
 /* Get number of minutes till lock expires form GI (-1 means never expires)  */
 select @temp = gi_string3 from generalinfo where gi_name = 'InvoicingRecordLocking'
 if ISNUMERIC(@temp) =  1
  BEGIN
    if (convert(int,@temp)) < 0  select @temp = NULL
  END

 if @temp is null or ISNUMERIC(@temp) <> 1
    select @expires = '20491231 23:59'
 else
  BEGIN
    select @expiremins = convert(int,@temp)
    select @expires = dateadd(mi,@expiremins,@now)
  
  END
  
  /* ?? Question do I want to delete all records for table and key where the expires datetime has passed to keep table clean?  */
  /* Application code tries to remove locks, but there could be orphans */
  delete from recordlockingtable 
  where rlt_table = @p_table
  and rlt_tablekey = @p_tablekey
  and rlt_lockexpires < @now 
  
  /* Add lock if no active lock exists for this object */ 
  /* maybe I check for a @@error on a dup key? rathe than if exists */ 
 if not exists (select 1 from recordlockingtable 
    where rlt_table = @p_table
    and rlt_tablekey = @p_tablekey)
    --and rlt_lockexpires > getdate())
    BEGIN
      Insert into recordlockingtable (rlt_table,rlt_tablekey,rlt_userid,rlt_applicationID,rlt_locktime,rlt_lockexpires)
      values(@p_table,@p_tablekey,@tmwuser,@p_appid,@now,@expires)
    END
    
/* Now get the latest lock info (hopefully the one I just added)  */   
Select @P_LockObtained = (case (rlt_userID + rlt_applicationID) when (@tmwuser  + @p_appid) then 'Y' else 'N' end)
,@p_Lockobtainedby =  rlt_userid
,@p_lockobtainedforAppID = rlt_applicationID
,@p_minuteslocked = datediff(mi,rlt_locktime,@now)
from recordlockingtable 
  where rlt_table = @p_table
  and rlt_tablekey = @p_tablekey




GO
GRANT EXECUTE ON  [dbo].[AddRecordLockingTableLock] TO [public]
GO
