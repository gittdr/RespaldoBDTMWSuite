SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_get_nc_group_candidates_sp] 
(
    @group_id int
)
AS

/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure. Get non-conformace email recipients' list excluding those from the given group.
TGRIFFIT 42695 06/05/2008 include Branch details in the member_name data

exec d_get_nc_group_candidates_sp 2

*/

BEGIN

    SELECT ncee_email_person_id,
       ncee_email_type,
       member_name = CASE WHEN ncee_email_type = 'E' THEN ncee_ext_description
                          ELSE usr_fname + ' ' +  usr_lname + ' (' 
                          +  ncee_int_usr_userid + ' ' + usr_type1 + ')' 
                     END
    FROM dbo.nce_email_info ei
        LEFT OUTER JOIN dbo.ttsusers
        ON ncee_int_usr_userid = usr_userid
    WHERE not exists (select 1 from dbo.nce_group_membership
                    where ncem_email_person_id = ei.ncee_email_person_id
                     and ncem_group_id = @group_id)
    return 0

END
GO
GRANT EXECUTE ON  [dbo].[d_get_nc_group_candidates_sp] TO [public]
GO
