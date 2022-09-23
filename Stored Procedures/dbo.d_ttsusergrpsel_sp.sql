SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[d_ttsusergrpsel_sp] as 

IF exists (select * from generalinfo where gi_name = 'DispatchUserListSortByName' and gi_string1 = 'Y')

	SELECT 'A' as idtype ,
			 ttsusers.usr_userid,
	        isnull (usr_fname, '') + ' '  + isnull (usr_lname, '') as name
	FROM ttsusers 
	UNION 
	SELECT DISTINCT 'B' as idtype , 
			ttsgroups.grp_id,
	         isnull (grp_name, '') as name
	FROM ttsgroups
	ORDER BY idtype desc, name asc

ELSE

	SELECT 'A' as idtype ,
			 ttsusers.usr_userid,
	        isnull (usr_fname, '') + ' '  + isnull (usr_lname, '') as name
	FROM ttsusers 
	UNION 
	SELECT DISTINCT 'B' as idtype , 
			ttsgroups.grp_id,
	         isnull (grp_name, '') as name
	FROM ttsgroups
	ORDER BY idtype desc, ttsusers.usr_userid asc

GO
GRANT EXECUTE ON  [dbo].[d_ttsusergrpsel_sp] TO [public]
GO
