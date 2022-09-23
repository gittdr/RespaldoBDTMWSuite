SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Function [dbo].[fnc_TMWRN_GreatPlainsConnectionInfo] (@Company varchar(255) = '')
Returns varchar(255)
As
Begin

Declare @MultiCompany bit
Declare @ServerName varchar(255)
Declare @DatabaseName varchar(255)

--grab the default connection info
--for the great plains database
Select Top 1
       @MultiCompany = Export_to_multicompany,
       @ServerName = Server_Name,
       @DatabaseName = DBname
From   gpdefaults (NOLOCK)


--If Multi Company then resolve the Server and Database
--from the labelfile
If @MultiCompany = 1 And Len(@Company) > 0 
Begin
	
	--If company entries are null fall back to
	--to the great plains default server and db
	Select Top 1
	       @ServerName = IsNull(acct_server,@ServerName),
	       @DatabaseName = IsNull(acct_db,@DatabaseName)
	From   labelfile (NOLOCK)
	Where  labelfile.labeldefinition = 'Company'
	       and
	       labelfile.name = @Company
	


End

Return '[' + @ServerName + '].[' + @Databasename + '].'

End



GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_GreatPlainsConnectionInfo] TO [public]
GO
