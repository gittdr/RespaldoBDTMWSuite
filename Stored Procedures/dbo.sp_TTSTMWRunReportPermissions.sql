SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO









CREATE       procedure [dbo].[sp_TTSTMWRunReportPermissions]
--exec sp_TTSTMWRunReportPermissions

AS

	Declare @RoleOrLogin varchar(255)
	Declare @ObjectID int
	Declare @DenyLogin varchar(255)
	Declare @CountGrantLogins int
	Declare @tmwuser varchar(255)
	Declare @ObjectSeq int
	Declare @tmwobject varchar(255)
	Declare @PermStatus char(1)

	Set @tmwuser = user

	

	Set @DenyLogin = ''
	Set @CountGrantLogins = 4
	Set @PermStatus = 'Y'	

	select identity(int,1,1) as ObjectSeq,rao_object,' ' as PermStatus 
	Into #TempMRSysTables
	From MR_CannedReportsAndObjects
	Where rao_source = 'MRSysTables'
	      and 
	      rao_object <> 'MR_ReportingSubsidiary'
	      and
	      rao_object <> 'MR_GeneralInfo' 
		
	
	Select @ObjectSeq = Min(ObjectSeq)
	from   #TempMRSysTables

	While @ObjectSeq Is Not Null
	Begin
	
		Select
	    	@tmwobject = (select rao_object
			     	 from   #TempMRSysTables 
                             	 where  ObjectSeq = @ObjectSeq)   


	Create Table #TMWObjectPermissions
	(
	Owner varchar(255),
	Object varchar(255),
	RoleOrLogin varchar(255),
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
		Insert into #TMWObjectPermissions (RoleOrLogin)
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

	--get any associated groups that are tied to the 
	--user so we can test permission later
	select sysusers.name as grp_name
	into   #TMWRolesForUser
	from   sysmembers   Inner Join sysusers On sysusers.uid = sysmembers.groupuid and sysusers.status = 0 
		    	    Inner Join sysusers b ON sysmembers.memberuid = b.uid and b.status <> 0
	where  b.name = @tmwuser 
	       and 
	       sysusers.name In (select RoleOrLogin from #TMWObjectPermissions) 

	--Perform tests for each scenario
	--check for denials
	--If any 
	select @DenyLogin = IsNull(RoleOrLogin,'')
	from   #TMWObjectPermissions
	where  ProtectType = 'Deny' and (ActionType = 'Select' or ActionType = 'Delete' or ActionType = 'Insert' or ActionType = 'Update')
	       And
	       (
		(RoleOrLogin = @tmwuser)
	        Or
                (RoleOrLogin In (select grp_name from #TMWRolesForUser))	
		Or
		('N' = IsNull((select Min('Y') from master..syslogins where (sysadmin = 1 And name = @tmwuser) Or @tmwuser = 'dbo'),'N') And RoleOrLogin = 'public')	
	      )	

	
	If @DenyLogin <> '' 
	Begin
		Update #TempMRSysTables Set PermStatus = 'N' where ObjectSeq = @ObjectSeq
		
	End
	Else
	Begin
		select @CountGrantLogins = count(distinct ActionType)
		from   #TMWObjectPermissions
		where  ProtectType = 'Grant' 
			and 
		       (ActionType = 'Select' or ActionType = 'Delete' or ActionType = 'Insert' or ActionType = 'Update')
			And
	       		(
			(RoleOrLogin = @tmwuser)
	        	Or
                	(RoleOrLogin In (select grp_name from #TMWRolesForUser))	
			Or
			('N' = IsNull((select Min('Y') from master..syslogins where (sysadmin = 1 And name = @tmwuser) Or @tmwuser = 'dbo'),'N') And RoleOrLogin = 'public')	
	      		)		
			

		select @RoleOrLogin = Min(RoleOrLogin)
		from   #TMWObjectPermissions
		where  ProtectType = 'Grant' 
			and 
		       (ActionType = 'Select' or ActionType = 'Delete' or ActionType = 'Insert' or ActionType = 'Update')
			And
	       		(
			(RoleOrLogin = @tmwuser)
	        	Or
                	(RoleOrLogin In (select grp_name from #TMWRolesForUser))	
			Or
			('N' = IsNull((select Min('Y') from master..syslogins where (sysadmin = 1 And name = @tmwuser) Or @tmwuser = 'dbo'),'N') And RoleOrLogin = 'public')	
	      		)	


		If @CountGrantLogins < 4 And @RoleOrLogin Is Not Null
		Begin
			Update #TempMRSysTables Set PermStatus = 'N' where ObjectSeq = @ObjectSeq
		
		End
		Else
		Begin
			Update #TempMRSysTables Set PermStatus = 'Y' where ObjectSeq = @ObjectSeq
		End

	End

		Drop Table #TMWRolesForUser
		Drop Table #TMWObjectPermissions

		Select @ObjectSeq = Min(ObjectSeq)
		from   #TempMRSysTables 
		Where
	       		ObjectSeq > @ObjectSeq

End


Select @PermStatus = 'N' 
From   #TempMRSysTables
Where  'N' In (select PermStatus from #TempMRSysTables)

Select IsNull(@PermStatus,'Y')





	
	












GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMWRunReportPermissions] TO [public]
GO
