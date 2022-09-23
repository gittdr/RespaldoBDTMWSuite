SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE  Procedure [dbo].[DriverAwareSuite_GetTTSUsers]

As

Select RTrim(usr_userid) as UserID
From   ttsusers (NOLOCK)





GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_GetTTSUsers] TO [public]
GO
