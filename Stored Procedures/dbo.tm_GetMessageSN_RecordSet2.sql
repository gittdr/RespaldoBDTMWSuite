SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/**
 * 
 * NAME:
 * dbo.tm_GetMessageSN_RecordSet2 
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 *Find a record set for TMailXFC  - CTMWMobcXFC or the tblmessage.sn 
 *
 * RETURNS:
 *  sn of recent message arrivals  
 *
 * RESULT SETS: 
 *  none
 *
 * PARAMETERS:

 *
 * REFERENCES:
 * 
 * REVISION HISTORY:
 * 05/7/2012.01 -  JC - created for PTS 59844
 * 2015/03/13 - rwolfe - PTS 87946 limit result set to avoid poller memory limits
 * 2015/04/07 - tdigi - added outset support.
 *
 **/
create proc [dbo].[tm_GetMessageSN_RecordSet2]
@Folder varchar(100), 
@MsgStatus varchar(100), 
@MCTypeSN varchar(100), 
@InstanceId varchar(100),
@MinTMailPriority varchar(100), 
@MsgSNsSoFar varchar(MAX),
@Config_result varchar(100),
@MaxRecords int = null,
@Outset int=1,
@OutsetCount int=1
as

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
Declare @sSQl nvarchar (2000)

--Create view
	
	 
	 if(isnull(@MaxRecords,0) > 0)
		Set @sSQl = N'SELECT TOP ' + CONVERT(varchar(22), @MaxRecords) + ' tblMessages.SN FROM tblMessages ';
	 else
		Set @sSQl = N'SELECT tblMessages.SN FROM tblMessages ';

	Set @sSQl = @sSQl + N' INNER JOIN tblCabUnits ON tblMessages.DeliverTo = tblCabUnits.UnitID'-- AND tblMessages.GetTMailMCommTypeSN = tblCabUnits.Type'
    Set @sSQl = @sSQl + N' WHERE Folder in (' + @Folder + ')'
    Set @sSQl = @sSQl + N' AND Status = ' + @MsgStatus
    
    If @MinTMailPriority > 0 
    Begin    
        Set @sSQl = @sSQl + N' AND Priority >=  ' + @MinTMailPriority
    End 
    
    If @MsgSNsSoFar <> '' 
    Begin
        Set @sSQl = @sSQl + N' AND tblMessages.SN Not IN ( ' + LTrim(Substring(@MsgSNsSoFar,2,DATALENGTH(@MsgSNsSoFar))) + ')'  --PTS 72963 DWG
    End
    
    --Set @sSQl = @sSQl + N' AND tblMessages.DeliverTo = tblCabUnits.UnitID '
    Set @sSQl = @sSQl + N' AND tblCabUnits.Type = ' + @MCTypeSN
    If @OutSetCount > 1
		BEGIN
        Set @sSQL = @sSQL + N' AND (tblCabUnits.SN % ' + CONVERT(nvarchar(10), @OutsetCount) + ') = '+ CONVERT(nvarchar(10), @Outset - 1)
        END
    Set @sSQl = @sSQl + N' AND ISNULL(tblCabUnits.OutInstanceId, ISNULL(tblCabUnits.InstanceId, 1)) =  ' + @InstanceId   -- Only pull messages for this Instance Id
    Set @sSQl = @sSQl + N' ORDER BY'
    

    If @config_result = 1
		Begin  
		 SET   @sSQl = @sSQl + ' Priority Desc,'
		end
		
	SET @sSQl = @sSQl + N' tblMessages.sn'
   
   Exec sp_executesql @sSQl   
GO
GRANT EXECUTE ON  [dbo].[tm_GetMessageSN_RecordSet2] TO [public]
GO
