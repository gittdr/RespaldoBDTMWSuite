SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_getassignedbackofficeviews_sp]
( @viewtype VARCHAR(6)
, @userid   VARCHAR(20)
, @appid    VARCHAR(20)
)
AS

/*
*
*
* NAME:
* dbo.d_getassignedbackofficeviews_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Stored Procedure to list Assigned Backoffice Views for a given user
*
* RETURNS:
*
* NOTHING:
*
* 06/09/2011 PTS56851 LOR - Created Initial Version
* 11/28/2012 PTS65917 SPN - Modified to indicate a view has been Modified
*
*/

--  SELECT a.bov_appid,a.bov_type,a.bov_id, v.bov_name
--    FROM backofficeassignviews a
--    JOIN backofficeview v on a.bov_appid = v.bov_appid and a.bov_type = v.bov_type and a.bov_id = v.bov_id
--   WHERE ( a.bova_userid = @userid )
--         AND (a.bov_type = @viewtype)
--         AND (a.bov_appid = @appid)
--         AND ( a.bova_usertype = 'USER' )
--   UNION
--
--  SELECT a.bov_appid,a.bov_type,a.bov_id, v.bov_name
--    FROM backofficeassignviews a
--    JOIN backofficeview v on a.bov_appid = v.bov_appid and a.bov_type = v.bov_type and a.bov_id = v.bov_id
--    join ttsgroupasgn on  a.bova_userid = ttsgroupasgn.grp_id
--   WHERE ( bova_userid = ttsgroupasgn.grp_id )
--         AND ( ( a.bov_type = @viewtype )
--         AND ( ttsgroupasgn.usr_userid = @userid )
--         AND( a.bova_usertype = 'GROUP' )
--         AND a.bov_appid = @appid )

SET NOCOUNT ON

BEGIN

DECLARE @tmwuser VARCHAR(255)

EXEC gettmwuser @tmwuser OUTPUT

  SELECT a.bov_appid                                                        			AS bov_appid
       , a.bov_type                                                         			AS bov_type
       , a.bov_id                                                           			AS bov_id
       , (CASE WHEN tv.bov_id IS NULL THEN '' ELSE '(Revised) ' END) + v.bov_name	AS bov_name
    FROM backofficeassignviews a
    JOIN backofficeview v ON a.bov_appid = v.bov_appid
                         AND a.bov_type = v.bov_type
                         AND a.bov_id = v.bov_id
  LEFT OUTER JOIN backofficeview_temp tv ON a.bov_appid = tv.bov_appid
                                        AND a.bov_type = tv.bov_type
                                        AND a.bov_id = tv.bov_id
                                        AND tv.tmwuser = @tmwuser
   WHERE a.bova_userid = @userid
     AND a.bov_type = @viewtype
     AND a.bov_appid = @appid
     AND a.bova_usertype = 'USER'
  UNION
  SELECT a.bov_appid                                                        			AS bov_appid
       , a.bov_type                                                         			AS bov_type
       , a.bov_id																							AS bov_id
       , (CASE WHEN tv.bov_id IS NULL THEN '' ELSE '(Revised) ' END) + v.bov_name	AS bov_name
    FROM backofficeassignviews a
    JOIN backofficeview v ON a.bov_appid = v.bov_appid
                         AND a.bov_type = v.bov_type
                         AND a.bov_id = v.bov_id
    JOIN ttsgroupasgn g ON a.bova_userid = g.grp_id
  LEFT OUTER JOIN backofficeview_temp tv ON a.bov_appid = tv.bov_appid
                                        AND a.bov_type = tv.bov_type
                                        AND a.bov_id = tv.bov_id
                                        AND tv.tmwuser = @tmwuser
   WHERE g.usr_userid = @userid
     AND a.bov_type = @viewtype
     AND a.bov_appid = @appid
     AND a.bova_usertype = 'GROUP'

END
GO
GRANT EXECUTE ON  [dbo].[d_getassignedbackofficeviews_sp] TO [public]
GO
