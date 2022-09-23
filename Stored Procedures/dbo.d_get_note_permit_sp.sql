SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_get_note_permit_sp]
		(@as_user_id 	  varchar(20),
		 @as_note_user_id varchar(20),
		 @ai_restricted_count int OUTPUT)
AS

/**
 *
 * NAME:
 * dbo.d_get_note_permit_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * 
 * RETURNS:
 *		Count of groups that user is a member of, that show up as restricted by the owner of the displayed note
 *
 * RESULT SETS:
 *
 * REVISION HISTORY:
 * Date ? 	PTS# - 	AuthorName ? Revision Description
 * 10/05/2007	35763	SLM	     Original Code
*/ 

SELECT @ai_restricted_count = count(n.note_rest_grp_id)
    FROM note_group_restriction as n, ttsgroupasgn t
   WHERE n.note_grp_id = t.grp_id
AND t.usr_userid = @as_note_user_id and n.note_rest_grp_id IN (select grp_id from ttsgroupasgn where usr_userid = @as_user_id )

Return @ai_restricted_count
GO
GRANT EXECUTE ON  [dbo].[d_get_note_permit_sp] TO [public]
GO
