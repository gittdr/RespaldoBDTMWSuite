SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[AssignmentPermissions_sp](
    @assettype char(3),
    @assetid varchar(13),
    @IncludeInactive char(1)
)

AS BEGIN
  SELECT ap.ap_id,   
         ap.ap_userid,   
         ap.ap_assettype,
         ap.ap_assetid,   
         ap.ap_expiration,   
         ap.ap_singleuse,   
         ap.ap_active
    FROM AssignmentPermissons  ap
   WHERE ( ap.ap_assettype = @assettype or @assettype = 'UNK' ) AND  
         ( ap.ap_assetid = @assetid or @assetid = 'UNKNOWN') AND
			( @IncludeInactive = 'Y' OR ap.ap_active = 'Y')

END

GO
GRANT EXECUTE ON  [dbo].[AssignmentPermissions_sp] TO [public]
GO
