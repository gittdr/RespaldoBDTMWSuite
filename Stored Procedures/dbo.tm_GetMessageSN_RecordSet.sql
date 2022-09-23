SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/**
 * 
 * NAME:
 * dbo.tm_GetMessageSN_RecordSet 
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
 * 2015/04/07 - tdigi - functionality ported to tm_GetMessageSN_RecordSet2 in the course of adding outset support.
 *
 **/
create proc [dbo].[tm_GetMessageSN_RecordSet]  
@Folder varchar(100), 
@MsgStatus varchar(100), 
@MCTypeSN varchar(100), 
@InstanceId varchar(100),
@MinTMailPriority varchar(100), 
@MsgSNsSoFar varchar(MAX),
@Config_result varchar(100),
@MaxRecords int = null

as

	exec tm_GetMessageSN_RecordSet2 @Folder, @MsgStatus, @MCTypeSN, @InstanceId, @MinTMailPriority, @MsgSNsSoFar, @Config_result, @MaxRecords, 1, 1
GO
GRANT EXECUTE ON  [dbo].[tm_GetMessageSN_RecordSet] TO [public]
GO
