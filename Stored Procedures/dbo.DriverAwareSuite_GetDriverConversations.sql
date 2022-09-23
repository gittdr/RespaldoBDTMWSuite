SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE       Procedure [dbo].[DriverAwareSuite_GetDriverConversations] (@DriverID varchar(255))

As

Set NOCount On

Select 
       --mpp_id as [DriverID],
       username as [User],
       [UserName]=IsNull((select Top 1 IsNull(usr_lname,'') + ', ' + IsNull(usr_fname,'') from ttsusers (NOLOCK) where ttsusers.usr_userid = username),username),
       logdate as [LogDate],
       conversation as [Conversation]
       

from   DriverAwareSuite_Conversation
Where  mpp_id = @DriverID
       --and
       --username = user
Order By logdate asc

















GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_GetDriverConversations] TO [public]
GO
