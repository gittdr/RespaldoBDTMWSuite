SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE PROCEDURE [dbo].[d_get_nc_groups_for_a_contact] 
(
    @person_id int
)
AS

/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure. Get nc group list where the given recipient belongs

exec d_get_nc_groups_for_a_contact 4, 'idv'
*/


BEGIN

    SELECT nceg_group_id,
           nceg_group_name
    FROM nce_groups
    INNER JOIN nce_group_membership
    ON nceg_group_id = ncem_group_id
    WHERE ncem_email_person_id = @person_id
     
    return 0
END

GO
GRANT EXECUTE ON  [dbo].[d_get_nc_groups_for_a_contact] TO [public]
GO
