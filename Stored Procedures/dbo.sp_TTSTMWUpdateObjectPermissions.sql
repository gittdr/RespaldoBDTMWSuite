SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO







CREATE     Procedure [dbo].[sp_TTSTMWUpdateObjectPermissions]

As

Declare @sqlobject varchar(255)
Declare @objectid int
Declare @grantee varchar(255)
Declare @objecttype varchar(255)
Declare @objectsource varchar(255)
Declare @reportname varchar(255)
Declare @loginorrole varchar(255)
Declare @protecttype varchar(100)
Declare @actiontype varchar(100)


Select identity(int,1,1) as ObjectID,TempMRPermissions.*
into #TempObjects
From

(

Select distinct perm_object,perm_objectsource,perm_objecttype
from   MR_Permissions

) as TempMRPermissions

Select @objectid = Min(ObjectID)
from   #TempObjects



--Revoke all permissions 
--ON OBJECT FROM THE DEFAULT
--PUBLIC ROLE
--It will add public if public has been selected
--previously to have permissions

--Set @SQL =

			
	While @objectid Is Not Null
	  Begin
	      Select @sqlobject = (select perm_object from #TempObjects  where ObjectID = @objectid) 
	      
	      Exec ('Revoke All On ' + @sqlobject + ' to public')

	      Select
	     	    @objectid = min(objectid)
	      From
	      	    #TempObjects
	      Where
	      	    objectid > @objectid

	  End



	Select identity(int,1,1) as ObjectID,perm_grantee,perm_object,perm_objectsource,perm_objecttype,perm_reportname
	into   #TempObjectPermissions
	from   MR_Permissions


	Select @objectid = Min(ObjectID)
	from   #TempObjectPermissions


	While @objectid Is Not Null
	  Begin
	      Select @sqlobject = (select perm_object from #TempObjectPermissions  where ObjectID = @objectid) 
	      Select @grantee = (select perm_grantee from #TempObjectPermissions  where ObjectID = @objectid) 
	      Select @objecttype = (select perm_objecttype from #TempObjectPermissions  where ObjectID = @objectid) 
	      Select @objectsource = (select perm_objectsource from #TempObjectPermissions  where ObjectID = @objectid) 
	      Select @reportname = (select perm_reportname from #TempObjectPermissions  where ObjectID = @objectid) 



	      Execute sp_TTSTMWGrantSQLObject  @grantee,@sqlobject,@objecttype,@objectsource,'Grant',@reportname

	      Select
	     	    @objectid = min(objectid)
	      From
	      	    #TempObjectPermissions 
	      Where
	      	    objectid > @objectid

	  End

Drop Table #TempObjects
Drop Table #TempObjectPermissions
--*********************Update MR Sys Table Permissions----------------
Select identity(int,1,1) as ObjectID,TempMRSysPermissions.*
into #TempMRSysTableObjects
From

(

Select distinct sysperm_object
from   MR_SysTablePermissions

) as TempMRSysPermissions

Select @objectid = Min(ObjectID)
from   #TempMRSysTableObjects

While @objectid Is Not Null
	  Begin
	      Select @sqlobject = (select sysperm_object from #TempMRSysTableObjects  where ObjectID = @objectid) 
	      
 	      --Reset all public access
	      Exec ('Revoke All On ' + @sqlobject + ' to public')
	
	      --Grant at least public permissions on each sys table object
	      Exec ('Grant Select On ' + @sqlobject + ' to public')

	      Select
	     	    @objectid = min(objectid)
	      From
	      	    #TempMRSysTableObjects
	      Where
	      	    objectid > @objectid

	  End



	Select identity(int,1,1) as ObjectID,sysperm_loginorrole,sysperm_object,sysperm_protecttype,sysperm_actiontype
	into   #TempMRSysTableObjectPermissions
	from   MR_SysTablePermissions


	Select @objectid = Min(ObjectID)
	from   #TempMRSysTableObjectPermissions


	While @objectid Is Not Null
	  Begin
	      Select @sqlobject = (select sysperm_object from #TempMRSysTableObjectPermissions  where ObjectID = @objectid) 
	      Select @loginorrole = (select sysperm_loginorrole from #TempMRSysTableObjectPermissions  where ObjectID = @objectid) 
	      Select @protecttype = (select sysperm_protecttype from #TempMRSysTableObjectPermissions  where ObjectID = @objectid) 
	      Select @actiontype = (select sysperm_actiontype from #TempMRSysTableObjectPermissions  where ObjectID = @objectid) 
	      

	      Execute sp_TTSTMWExecutePermissionOnSQLObject  @loginorrole,@sqlobject,'U','',@protecttype,@actiontype,'',''

	      Select
	     	    @objectid = min(objectid)
	      From
	      	    #TempMRSysTableObjectPermissions
	      Where
	      	    objectid > @objectid

	  End


Drop Table #TempMRSysTableObjects
Drop Table #TempMRSysTableObjectPermissions







GO
