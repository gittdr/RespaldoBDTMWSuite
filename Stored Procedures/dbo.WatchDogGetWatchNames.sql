SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE  Procedure [dbo].[WatchDogGetWatchNames]

As

	SET NOCOUNT ON

Declare @Prefix varchar(255)
Declare @SQL varchar(4000)

Set @Prefix = dbo.fnc_TMWRN_TmwSuiteLiveConnectionInfo()

If Len(@Prefix)>0
Begin


	Set @SQL = 'Select RTrim(name) as ProcName from ' + @Prefix + 'dbo.sysobjects where Left(name,9) = ' + '''' + 'WatchDog_'  + '''' + 'and type=' + '''' + 'P' + '''' + ' order by ProcName'
	Exec(@SQL)

End
Else
Begin

	Select RTrim(name) as ProcName from sysobjects (NOLOCK) where Left(name,9) = 'WatchDog_' and type='P' order by ProcName


End

--Select  syscol.name as parametername from CleDevCust1.ArrowGP.dbo.sysobjects sysobj, CleDevCust1.ArrowGP.dbo.syscolumns syscol where sysobj.name = '' and syscol.id = sysobj.id

--Select  syscol.name as parametername from CleDevCust1.ArrowGP.dbo.sysobjects sysobj, CleDevCust1.ArrowGP.dbo.syscolumns syscol where sysobj.name = '' and syscol.id = sysobj.id



GO
GRANT EXECUTE ON  [dbo].[WatchDogGetWatchNames] TO [public]
GO
