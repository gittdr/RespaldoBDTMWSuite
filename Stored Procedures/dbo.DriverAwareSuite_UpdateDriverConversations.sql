SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO





CREATE          Procedure [dbo].[DriverAwareSuite_UpdateDriverConversations] (@DriverID varchar(255),@Conversation varchar(1000),@LogDate datetime=Null)

As

Set NOCount On

Declare @LogDatePassed datetime

Set @LogDatePassed = @LogDate

If @LogDate Is Null
Begin
	Set @LogDate = Cast(Cast(getdate() as float)as smalldatetime)
End

--Updating the Record (that was just recently added by the user within the second)
--if the user has already inserted a conversation within the same minute and second
if  exists (select mpp_id from DriverAwareSuite_Conversation where mpp_id = @DriverID and logdate = @LogDate and username = system_user)

	Update DriverAwareSuite_Conversation
	Set    conversation = @Conversation
	Where  mpp_id = @DriverID
	       And
               logdate = @LogDate
	       And
               username = system_user
--Updating the conversation Record from history
--based on Driver ID and Log Date
--else if @LogDatePassed Is Not Null And exists (select mpp_id from DriverSAT_Conversation where mpp_id = @DriverID and logdate = @LogDate)

	--Update DriverSAT_Conversation
	--Set    conversation = @Conversation,
	       --username = user
        --Where  mpp_id = @DriverID
	      -- And
              -- logdate = @LogDate
else --Insert a new conversation
	Insert into DriverAwareSuite_Conversation (mpp_id,conversation,logdate,username) Values (@DriverID,@Conversation,Cast(Cast(getdate() as float)as smalldatetime),system_user)
    
	





GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_UpdateDriverConversations] TO [public]
GO
