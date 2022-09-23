SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO












CREATE            Procedure [dbo].[sp_TTSTMWExecutePermissionOnSQLObject](@roleorlogin varchar(255),@sqlobject varchar(255),@objecttype varchar(255),@objectsource varchar(255),@protecttype varchar(255),@actiontype varchar(255),@reportname varchar(255),@previousprotecttype varchar(255))
--Execute sp_TTSTMWExecutePermissionOnSQLObject 'cft','sp_TTSTMWmileagesummary','P','CannedReport','Grant','Mileage Summary'


As

Declare @sql varchar(8000)

--Set the permission for anything other then select
--it has been decided for Management Reporting to operate
--normally system tables at least need to have Select Rights
--By default all users will piggy back off the public rights 
--for select there is no need to deny,revoke, or grant
--select rights on a individual login or role basis
--because all users will at least have read or select rights
If @actiontype <> 'Select' and @objecttype = 'U' 
Begin

	Set @sql = @protecttype + ' ' + @actiontype +  ' ON ' + @sqlobject + ' TO ' + '[' + @roleorlogin + ']'
				
	Exec (@SQL)

				
	--Update MRSysTable PermissionTable
	If @protecttype = 'Grant' or @protecttype = 'Deny'
	Begin
   

		Set @SQL = 'Delete from MR_SysTablePermissions where sysperm_loginorrole = ' + '''' + @roleorlogin + '''' +  ' And sysperm_object = ' + '''' +  @sqlobject + '''' +  ' And sysperm_protecttype = ' + '''' +  @protecttype + '''' +  ' And sysperm_actiontype = ' + '''' +  @actiontype + ''''
          
        	Exec (@SQL)	

		Set @SQL = 'Insert into MR_SysTablePermissions (sysperm_loginorrole,sysperm_object,sysperm_protecttype,sysperm_actiontype) Values (' + '''' + @roleorlogin + '''' + ',' + '''' + @sqlobject + '''' + ',' + '''' +  @protecttype + '''' + ','  + '''' +  @actiontype + '''' + ')'
          
        	Exec (@SQL) 
  
	End
	Else --must be revoke
	Begin

		Set @SQL = 'Delete from MR_SysTablePermissions where sysperm_loginorrole = ' + '''' + @roleorlogin + '''' +  ' And sysperm_object = ' + '''' +  @sqlobject + '''' +  ' And sysperm_protecttype = ' + '''' +  @previousprotecttype + '''' +  ' And sysperm_actiontype = ' + '''' +  @actiontype + ''''
          
        	Exec (@SQL)

	End				
		

End















GO
