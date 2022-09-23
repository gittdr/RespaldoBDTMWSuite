SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[datawindow_security] (
	@ObjectName	VARCHAR(255),
	@UserID		VARCHAR(30),
	@objectname2	varchar(255))

AS
/*

2/20/07 pts32915 DPETE old rerstrictions lost when a new one is added
*/

Create Table #permission 
	(per_columnname	varchar(40) null,
	per_idtype	char(1)	null,
	per_accesslevel	int	null,
	per_validate	varchar(1000)	null,
	per_errmessage	varchar(512) null,
	per_accesslevel_rule varchar(1000) null
	)

/* PTS 31097 - DJM - New select using the @objectname2 parameter. This parameter should contain the
	datawindow control name so that Security will work correctly when there are
	multiple data window controls on a window with the same datawindow object	*/
Insert Into #permission
SELECT	ttspermission.per_columnname, 
	ttspermission.per_idtype,
  	ttspermission.per_accesslevel, 
	ttspermission.per_validate,
	ttspermission.per_errmessage,
	ttspermission.per_accesslevel_rule
FROM	ttspermission
WHERE	(ttspermission.per_objectname = @ObjectName2 AND
	 ((ttspermission.per_idtype = 'A' AND ttspermission.per_id = @UserID) OR
	  (ttspermission.per_idtype = 'B' 
		AND ttspermission.per_id IN (SELECT	ttsgroupasgn.grp_id
						 FROM	ttsgroupasgn
						 WHERE	ttsgroupasgn.usr_userid = @UserID))))

/* OLD method of finding the window/datawindow without the datawindow control name. Left in 
	for compatability with exiting DW security setups.					*/
--if (select count(*) from #permission) < 1 
	Insert Into #permission
	SELECT	ttspermission.per_columnname, 
		ttspermission.per_idtype,
	  	ttspermission.per_accesslevel, 
		ttspermission.per_validate,
		ttspermission.per_errmessage,
		ttspermission.per_accesslevel_rule
	FROM ttspermission
	WHERE (ttspermission.per_objectname = @ObjectName AND
		 ((ttspermission.per_idtype = 'A' AND ttspermission.per_id = @UserID) OR
		  (ttspermission.per_idtype = 'B' 
			AND ttspermission.per_id IN (SELECT	ttsgroupasgn.grp_id
							 FROM	ttsgroupasgn
							 WHERE	ttsgroupasgn.usr_userid = @UserID))))
	/*ORDER BY ttspermission.per_columnname ASC, 
			 ttspermission.per_idtype ASC, 
			 ttspermission.per_accesslevel ASC
	*/


Select per_columnname,
	per_idtype,
	per_accesslevel,
	per_validate,
	per_errmessage,
	per_accesslevel_rule
from #permission
ORDER BY per_columnname ASC, 
	 per_idtype ASC, 
	 per_accesslevel ASC

drop table #permission

GO
GRANT EXECUTE ON  [dbo].[datawindow_security] TO [public]
GO
