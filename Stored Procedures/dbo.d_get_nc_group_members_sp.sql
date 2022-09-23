SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_get_nc_group_members_sp] 
(
    @group_id int
)
AS

/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure. Get non-conformace email recipients' information based on the given group id or contact id
TGRIFFIT 42695 06/05/2008 include Branch details in the member_name data


exec d_get_nc_group_members_sp 4, 'idv'
*/

BEGIN

    SELECT ncem_email_person_id,
           ncem_group_id,
           ncee_email_type,
           member_name = CASE WHEN ncee_email_type = 'E' THEN ncee_ext_description 
                              ELSE usr_fname + ' ' +  usr_lname + ' (' 
                              +  ncee_int_usr_userid + ' ' + usr_type1 + ')'
                         END
    
           
    FROM dbo.nce_group_membership
        INNER JOIN dbo.nce_email_info
        ON dbo.nce_group_membership.ncem_email_person_id = dbo.nce_email_info.ncee_email_person_id
        LEFT OUTER JOIN dbo.ttsusers 
        ON dbo.nce_email_info.ncee_int_usr_userid = dbo.ttsusers.usr_userid
    WHERE dbo.nce_group_membership.ncem_group_id = @group_id
    
    return 0

END

GO
GRANT EXECUTE ON  [dbo].[d_get_nc_group_members_sp] TO [public]
GO
