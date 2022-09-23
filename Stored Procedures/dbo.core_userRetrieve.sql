SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[core_userRetrieve]
    @usr_userid char(20)
AS
SELECT 
    usr_sysadmin,
	usr_supervisor
FROM [ttsusers]
WHERE
	usr_userid = @usr_userid

--get the groups this user belongs to
SELECT 
    ttsgroups.grp_id, 
    ttsgroups.grp_name 
From [ttsgroups]
INNER JOIN [ttsgroupasgn] 
    ON ttsgroups.grp_id = ttsgroupasgn.grp_id
WHERE 
    ttsgroupasgn.usr_userid = @usr_userid 
	



GO
GRANT EXECUTE ON  [dbo].[core_userRetrieve] TO [public]
GO
