SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[d_backofficeusergrpsel_sp] as 

SELECT 'U' as idtype ,
			 ttsusers.usr_userid,
	        isnull (usr_fname, '') + ' '  + isnull (usr_lname, '') as name
FROM ttsusers 
	
UNION 

SELECT DISTINCT 'G' as idtype , 
			ttsgroups.grp_id,
	         isnull (grp_name, '') as name
FROM ttsgroups
ORDER BY idtype desc, ttsusers.usr_userid asc
	
GO
GRANT EXECUTE ON  [dbo].[d_backofficeusergrpsel_sp] TO [public]
GO
