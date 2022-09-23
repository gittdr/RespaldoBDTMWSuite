SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO





CREATE   Proc [dbo].[sp_TTSTMWCheckAVLServerAndDatabase] (@ServerName varchar(255),@DatabaseName varchar(255),@UserName varchar(255))

As

Declare @AccessFlag as bit

Set @AccessFlag = 
		IsNull((Select 0 From MR_ServerAndDatabaseAccess WITH (NOLOCK) Where ServerName = @ServerName
									 	And
      									 	DatabaseName = @DatabaseName
									 	And
									 	UserName = @UserName
		),case when (select count(*) From MR_ServerAndDatabaseAccess WITH (NOLOCK) where ServerName = @ServerName
									 		    And
      									 		    DatabaseName = @DatabaseName) > 0 Then 1 Else 0 End)



Select @AccessFlag




GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMWCheckAVLServerAndDatabase] TO [public]
GO
