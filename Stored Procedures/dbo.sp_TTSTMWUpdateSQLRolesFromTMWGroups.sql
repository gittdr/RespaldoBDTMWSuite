SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO










CREATE        Procedure [dbo].[sp_TTSTMWUpdateSQLRolesFromTMWGroups]

As

Set NoCount On

Declare @GroupSeq     int
Declare @tmwgroupname varchar(8000)
Declare @tmwgroupid   varchar(8000)
Declare @tmwlogin     varchar(8000)
Declare @LoginSeq     int
Declare @NumberOfMembers int

--Detect what groups are needed to be converted
--from tmw to sql server roles

select identity(int,1,1) as GroupSeq,grp_id,grp_name 
into   #TempMissingRolesInSQL
from   ttsgroups Left Join sysusers On sysusers.name = ttsgroups.grp_name and status=0
Where  sysusers.name Is Null
       
Select @GroupSeq = Min(GroupSeq)
from   #TempMissingRolesInSQL

While @GroupSeq Is Not Null
Begin
	
	Select
	    @tmwgroupname = (select grp_name 
			     from   #TempMissingRolesInSQL 
                             where  GroupSeq = @GroupSeq)   


	Select
	    @tmwgroupid =  (select  grp_id 
			     from   #TempMissingRolesInSQL 
                             where  GroupSeq = @GroupSeq) 

	--Add TMW group as a SQL Server Role
	Exec sp_addrole @tmwgroupname

	--Add to converted tmw groups table
	--so we can later default those to automically
	--sync up with
	Insert Into MR_ConvertedTMWGroups (cnv_grpid,cnv_rolename,cnv_syncwithtmw) Values (@tmwgroupid,@tmwgroupname,1)

	select identity(int,1,1) as LoginSeq,usr_userid 
	into   #TempTMWGroupMembers
	from   ttsgroupasgn
	where  ttsgroupasgn.grp_id = @tmwgroupid
	
	Select @LoginSeq = Min(LoginSeq)
	from   #TempTMWGroupMembers
	
	While @LoginSeq Is Not Null
	Begin
	
		
		Select
	    	 @tmwlogin = (select usr_userid 
			     from   #TempTMWGroupMembers
                             where  LoginSeq = @LoginSeq)   

		--add logins to new role/group
		exec sp_addrolemember @tmwgroupname,@tmwlogin
		

		Select @LoginSeq = Min(LoginSeq)
		from   #TempTMWGroupMembers
		Where
	       		LoginSeq > @LoginSeq


	End


	Drop Table #TempTMWGroupMembers

	Select @GroupSeq = Min(GroupSeq)
	from   #TempMissingRolesInSQL
	Where
	       GroupSeq > @GroupSeq

End


--**ADD Login to Roles that are Synced with TMW Groups****************************************************

--Add or Delete members from the role
--for synced roles only


--Add logins to roles that need to be synced up with 
--TMW Group User Assignments
select identity(int,1,1) as LoginSeq,usr_userid,ttsgroups.grp_id,grp_name
into   #TempAddLoginToRole
from   ttsgroupasgn Inner Join ttsgroups  On ttsgroupasgn.grp_id = ttsgroups.grp_id
		    Inner Join MR_ConvertedTMWGroups On  MR_ConvertedTMWGroups.cnv_grpid =  ttsgroups.grp_id
		    Inner Join sysusers   On sysusers.name = ttsgroups.grp_name and sysusers.status = 0
		    Left Join sysusers b  On TTSgroupasgn.usr_userid = b.name and b.status <> 0
		    Left Join sysmembers On sysusers.uid = sysmembers.groupuid and sysmembers.memberuid = b.uid
		    
where  
       SYSMEMBERS.MEMBERUID Is Null	
       And     	
       --sync on roles/groups that the user wants to
       --enabled for syncing between tmw and sql
       MR_ConvertedTMWGroups.cnv_syncwithtmw = 1
       
Select @LoginSeq = Min(LoginSeq)
from   #TempAddLoginToRole
	
	While @LoginSeq Is Not Null
	Begin
	
		
		Select
	    	 @tmwlogin = (select usr_userid 
			     from    #TempAddLoginToRole
                             where   LoginSeq = @LoginSeq)   

		Select
	    	 @tmwgroupname = (select grp_name
			          from   #TempAddLoginToRole
                                  where  LoginSeq = @LoginSeq)   


		--add new logins to the existing synced role/group
		exec sp_addrolemember @tmwgroupname,@tmwlogin
		

		Select @LoginSeq = Min(LoginSeq)
		from   #TempAddLoginToRole
		Where
	       		LoginSeq > @LoginSeq


	End


--**DELETE Logins assigned to roles that no longer exist in TMW************************************************

--Delete logins to roles that are no longer  
--TMW Group Assignments for that specific group
select identity(int,1,1) as LoginSeq,b.name as userid,sysusers.name as grp_name
into   #TempDropRoleMemeber
from   sysmembers   Inner Join sysusers On sysusers.uid = sysmembers.groupuid and sysusers.status = 0 
		    Inner Join sysusers b ON sysmembers.memberuid = b.uid and b.status <> 0
		    Inner Join MR_ConvertedTMWGroups On  MR_ConvertedTMWGroups.cnv_rolename = sysusers.name
                    Left Join TTSgroupasgn  On TTSgroupasgn.usr_userid = b.name And  MR_ConvertedTMWGroups.cnv_grpid = TTSgroupasgn.grp_id
		    
where  
       ttsgroupasgn.usr_userid Is Null	
       And     	
       --sync on roles/groups that the user wants to
       --enabled for syncing between tmw and sql
       MR_ConvertedTMWGroups.cnv_syncwithtmw = 1
       	

Select @LoginSeq = Min(LoginSeq)
from   #TempDropRoleMemeber
	
	While @LoginSeq Is Not Null
	Begin
	
		
		Select
	    	 @tmwlogin = (select userid
			     from    #TempDropRoleMemeber
                             where   LoginSeq = @LoginSeq)   

		Select
	    	 @tmwgroupname = (select grp_name
			          from   #TempDropRoleMemeber
                                  where  LoginSeq = @LoginSeq)   


	
		exec sp_droprolemember @tmwgroupname,@tmwlogin
		
		Create Table #TempRoleMembers
	       (DBRole varchar(255),
 	        MemberName varchar(255),
	        MemberSID int
                ) 	 	

	        Insert Into #TempRoleMembers
	        exec sp_helprolemember @tmwgroupname

	        Select @NumberofMembers = Count(*)
                From   #TempRoleMembers
	
	        If @NumberOfMembers =0 
	        Begin
	           exec sp_droprole  @tmwgroupname
	        End
    
	        Drop Table #TempRoleMembers		

		
	        Select @LoginSeq = Min(LoginSeq)
	        from   #TempDropRoleMemeber
	        Where
	               LoginSeq > @LoginSeq


	End


--**DROP synced roles in SQL that no longer exist in TMWSuite************************************************
--This only drops roles no longer has users attached
--And 
--is setup to sync from TMWSuite
--Roles not synced up with TMWSuite are not dropped

select identity(int,1,1) as GroupSeq,sysusers.name as grp_name 
into   #TempMissingRolesInTMWSuite
from   sysusers Left Join ttsgroups On sysusers.name = ttsgroups.grp_name and status=0
		Inner Join MR_ConvertedTMWGroups on MR_ConvertedTMWGroups.cnv_rolename = sysusers.name
Where  ttsgroups.grp_name Is Null
       And
       (select count(*) from sysmembers where sysmembers.groupuid = sysusers.uid) = 0
       And
       cnv_syncwithtmw = 1       

Select @GroupSeq = Min(GroupSeq)
from   #TempMissingRolesInTMWSuite

While @GroupSeq Is Not Null
Begin
	
	Select
	    @tmwgroupname = (select grp_name 
			     from   #TempMissingRolesInTMWSuite
                             where  GroupSeq = @GroupSeq)   

	--Drop SQL Server Role
	Exec sp_droprole @tmwgroupname

	--Drop entry in MR_ConvertedTMWGroups
        --so we can say this role is no longer
	--synced between TMW and SQL
	Delete from MR_ConvertedTMWGroups where cnv_rolename = @tmwgroupname

	Select @GroupSeq = Min(GroupSeq)
	from   #TempMissingRolesInTMWSuite
	Where
	       GroupSeq > @GroupSeq

End
	
--Delete any previous entries in the MR_Permissions Table
--that are currently no longer an active role or login
Delete from MR_Permissions 
Where perm_grantee Not In (select name from sysusers)

--Delete any previous entries in the MR_SysTablePermissions table
--that are currently no longer an active role or login
Delete from MR_SysTablePermissions
Where sysperm_loginorrole Not In (select name from sysusers)


Set NoCount Off







GO
