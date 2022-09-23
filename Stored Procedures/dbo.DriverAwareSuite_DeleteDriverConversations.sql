SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE     Procedure [dbo].[DriverAwareSuite_DeleteDriverConversations] (@DriverID varchar(255),@LogDate datetime)

As

Set NOCount On

Delete from DriverAwareSuite_Conversation where mpp_id = @DriverID and logdate = @LogDate
    
	









GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_DeleteDriverConversations] TO [public]
GO
