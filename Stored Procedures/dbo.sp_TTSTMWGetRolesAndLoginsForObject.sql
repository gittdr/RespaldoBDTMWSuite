SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO








CREATE        Procedure [dbo].[sp_TTSTMWGetRolesAndLoginsForObject] (@tmwobject as varchar(8000))

--sp_helprotect 'vTTSTMW_CarrierProfile'
--exec sp_TTSTMWGetRolesAndLoginsForObject 'vTTSTMW_CarrierProfile'

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


	--Detect if any permissions are populated 
	--in the sysprotects table
	select @ObjectID =  min(sysprotects.id) 
	from   sysprotects,sysobjects
	where  sysprotects.id = sysobjects.id
       	       And
       	       sysobjects.name = @tmwobject

	--If Nothing is populated Detect what users
	--have permissions from the syspermissions table
	--If Not work from the protects table by
	--using the sp_helprotect proc
	If @ObjectId Is Null
	   Begin
		Insert into #TMWObjectPermissions (Grantee)
		select sysusers.name
		from   syspermissions,sysobjects,sysusers
		where  sysobjects.id = syspermissions.id
       	       	       and 
                       sysusers.uid = syspermissions.grantee	
	               And
	               sysobjects.name = @tmwobject

	  End
	  Else
	  Begin

		Insert into #TMWObjectPermissions 
		Exec sp_helprotect @tmwobject
	  End


	select Grantee
	from   #TMWObjectPermissions
	where  (@ObjectID Is Not Null And (ActionType = 'Select' or ActionType = 'Execute'))
	        OR
               (@ObjectID Is Null)

 





GO
