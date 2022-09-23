SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create procedure [dbo].[get_user_groups]
		(@user_id	varchar(6))
as

/**
 * 
 * NAME:
 * dbo.get_user_groups
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return set of groups to which a user is assigned
 *
 * RETURNS:
 * na
 *
 * RESULT SETS: 
 * GroupId
 *
 * PARAMETERS:
 * 001 - @user_id, char(20), input, null;
 *       The user ID
 *
 * REFERENCES: 
 * 09/08/2006.01 - PTS33925 - vjh - Original code
 *
 **/

select grp_id
from ttsgroupasgn
where usr_userid = @user_id

GO
GRANT EXECUTE ON  [dbo].[get_user_groups] TO [public]
GO
