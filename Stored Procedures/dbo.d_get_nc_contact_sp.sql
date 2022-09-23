SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_get_nc_contact_sp]
(
    @id int, 
    @id_type char(3) 
)
AS

/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure. Get non-conformace email recipients' information based on the given group id or contact id
TGRIFFIT 42695 06/05/2008 - added CASE stmnts around usr_fname + usr_lname - if null then return usr_userid - this will prevent issue where individual contacts are displayed in the treeview dw, but all name info missing.


exec d_get_nc_contact_sp 4, 'idv'
*/

BEGIN
    if @id_type = 'grp'
      SELECT nce_email_info.ncee_email_person_id,
             nce_email_info.ncee_email_address,
             nce_email_info.ncee_email_type,
             nce_email_info.ncee_ext_description,
             nce_email_info.ncee_int_usr_userid,
             --ttsusers.usr_fname,
             --ttsusers.usr_lname,
             CASE WHEN ttsusers.usr_fname IS NULL THEN ttsusers.usr_userid 
                ELSE ttsusers.usr_fname END usr_fname,
             CASE WHEN ttsusers.usr_lname IS NULL THEN ttsusers.usr_userid 
                ELSE ttsusers.usr_lname END usr_lname,
             ttsusers.usr_type1,
             nce_email_info.created,
             nce_email_info.created_by,
             nce_email_info.updated,
             nce_email_info.updated_by
        FROM nce_group_membership
            INNER JOIN nce_email_info
            ON nce_group_membership.ncem_email_person_id = nce_email_info.ncee_email_person_id
            LEFT OUTER JOIN ttsusers
            ON nce_email_info.ncee_int_usr_userid = ttsusers.usr_userid
        WHERE nce_group_membership.ncem_group_id = @id
       
    else
      SELECT nce_email_info.ncee_email_person_id,
             nce_email_info.ncee_email_address,
             nce_email_info.ncee_email_type,
             nce_email_info.ncee_ext_description,
             nce_email_info.ncee_int_usr_userid,
             --ttsusers.usr_fname,
             --ttsusers.usr_lname,
             CASE WHEN ttsusers.usr_fname IS NULL THEN ttsusers.usr_userid 
                ELSE ttsusers.usr_fname END usr_fname,
             CASE WHEN ttsusers.usr_lname IS NULL THEN ttsusers.usr_userid 
                ELSE ttsusers.usr_lname END usr_lname,
             ttsusers.usr_type1,
             nce_email_info.created,
             nce_email_info.created_by,
             nce_email_info.updated,
             nce_email_info.updated_by
        FROM nce_email_info
            LEFT OUTER JOIN ttsusers
            ON nce_email_info.ncee_int_usr_userid = ttsusers.usr_userid
       WHERE nce_email_info.ncee_email_person_id = @id
    
    return 0
END

GO
GRANT EXECUTE ON  [dbo].[d_get_nc_contact_sp] TO [public]
GO
