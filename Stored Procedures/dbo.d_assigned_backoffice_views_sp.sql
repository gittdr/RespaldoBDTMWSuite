SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_assigned_backoffice_views_sp] @viewtype varchar(6), @userid varchar(20), @appid varchar(20)
AS

  SELECT bov_id, bov_validviews,1  
    FROM backofficeassignviews
   WHERE ( bova_userid = @userid ) AND  
         ( bova_usertype = 'USER' ) AND  
         ( bov_type = @viewtype )   and
         bov_appid = @appid
   UNION   
  SELECT bov_id, bov_validviews, 2  
    FROM backofficeassignviews, ttsgroupasgn  
   WHERE ( bova_userid = ttsgroupasgn.grp_id ) and  
         ( ( bov_type = @viewtype ) AND  
         ( ttsgroupasgn.usr_userid = @userid ) AND  
         ( bova_usertype = 'GROUP' )  and
         bov_appid = @appid )    


GRANT EXECUTE ON d_assigned_backoffice_views_sp TO PUBLIC

GO
