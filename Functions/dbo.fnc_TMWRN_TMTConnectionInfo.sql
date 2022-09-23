SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Function [dbo].[fnc_TMWRN_TMTConnectionInfo] ()
Returns varchar(255)
As
Begin

Declare @ServerName varchar(255)
Declare @DatabaseName varchar(255)

Select Top 1
       @ServerName = gi_string1,
       @DatabaseName = gi_string2
From   generalinfo (NOLOCK)
Where  gi_name = 'Shoplink'


Return @ServerName + '.' + @Databasename + '.'

End



GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_TMTConnectionInfo] TO [public]
GO
