SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE             Procedure [dbo].[sp_TTSTMWGetAvailableRolesAndLogins] (@tmwobject as varchar(8000))

--sp_helprotect 'vTTSTMW_CarrierProfile'
--exec sp_TTSTMWGetRolesAndLoginsForObject 'vTTSTMW_InvoiceInformation'

As

Declare @ObjectID int

Create Table #TMWObjectPermissions
	(
	Owner varchar(255),
	Object varchar(255),
	Grantee varchar(255),
	Grantor varchar(255),
	ProtectType varchar(255),
	ActionType varchar(255),
	Cols varchar(255)
	)

select @ObjectID =  min(sysprotects.id) 
from   sysprotects,sysobjects
where  sysprotects.id = sysobjects.id
       And
       sysobjects.name = @tmwobject



If @ObjectID Is Not Null 
	Begin
	    Insert into #TMWObjectPermissions
            Exec sp_helprotect @tmwobject

	End
	Else

	Begin
	
		Insert into #TMWObjectPermissions (Grantee)
        	select sysusers.name
		from   syspermissions,sysobjects,sysusers
		where  sysobjects.id = syspermissions.id
       	       	       and 
               	       sysusers.uid = syspermissions.grantee	
		       and
	               sysobjects.name = @tmwobject    

	End


	select name as RoleOrLogin,Case When status = 0 Then 'Group/Role' Else 'User/Login' End as Type
	from   sysusers Left Join #TMWObjectPermissions On sysusers.name = #TMWObjectPermissions.Grantee
	where  #TMWObjectPermissions.Grantee Is Null
	       and
	       name Not Like 'db_%'
	order by name











GO
