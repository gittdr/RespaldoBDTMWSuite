SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_get_nc_group_sp] 
(
    @group_id int
)
AS

/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure. Get non-conformace contact group information based on the given group id

exec d_get_nc_group_sp 2

*/

BEGIN

    if @group_id = 0
        SELECT  
             nceg_group_id,
             nceg_group_name,
             isnull(match_level, 'N') match_level,
             updated,   
             updated_by,   
             created_by,   
             created  
        FROM nce_groups
    
    else
        SELECT  
             nceg_group_id,
             nceg_group_name,
             isnull(match_level, 'N') match_level,
             updated,   
             updated_by,   
             created_by,   
             created  
        FROM nce_groups
        WHERE nceg_group_id = @group_id 

END

GO
GRANT EXECUTE ON  [dbo].[d_get_nc_group_sp] TO [public]
GO
