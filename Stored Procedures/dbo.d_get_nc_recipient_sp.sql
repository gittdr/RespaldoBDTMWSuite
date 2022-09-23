SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_get_nc_recipient_sp] 
(
    @id int
)
AS

/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure. Get non-conformace email recipients' information for one or all recipients. 
TGRIFFIT 42695 06/05/2008 - added outer LTRIM when concatanating 'Recipient' data to remove leading spaces
if usr_fname/usr_lname data is null/missing. 

exec d_get_nc_recipient_sp 0
exec d_get_nc_recipient_sp 10

*/

BEGIN

    if @id > 0 
    begin
        SELECT 
             ncee_email_person_id,
             ncee_email_address,
             ncee_email_type,
             ncee_ext_description,
             ncee_int_usr_userid,
             usr_fname,
             usr_lname,
             usr_type1,
             created,
             created_by,
             updated,
             updated_by,
             LTRIM(usr_fname + ' ' +  usr_lname + ' (' + ltrim(rtrim(usr_userid)) + ')') 'recipient'
        FROM nce_email_info
            INNER JOIN ttsusers
            ON ncee_int_usr_userid = usr_userid
        WHERE ncee_email_type = 'I'
         and ncee_email_person_id = @id
        
        UNION 
        SELECT 
             ncee_email_person_id,
             ncee_email_address,
             ncee_email_type,
             ncee_ext_description,
             ncee_int_usr_userid,
             NULL,
             NULL,
             NULL,
             created,
             created_by,
             updated,
             updated_by,
             ncee_ext_description
        FROM nce_email_info
        WHERE ncee_email_type = 'E'
          and ncee_email_person_id = @id
    end
    else
    begin
        SELECT 
             ncee_email_person_id,
             ncee_email_address,
             ncee_email_type,
             ncee_ext_description,
             ncee_int_usr_userid,
             usr_fname,
             usr_lname,
             usr_type1,
             created,
             created_by,
             updated,
             updated_by,
             LTRIM(usr_fname + ' ' +  usr_lname + ' (' + ltrim(rtrim(usr_userid)) + ')') 'recipient'
        FROM nce_email_info
            INNER JOIN ttsusers
            ON ncee_int_usr_userid = usr_userid
        WHERE ncee_email_type = 'I'    
        UNION 
        SELECT 
             ncee_email_person_id,
             ncee_email_address,
             ncee_email_type,
             ncee_ext_description,
             ncee_int_usr_userid,
             NULL,
             NULL,
             NULL,
             created,
             created_by,
             updated,
             updated_by,
             ncee_ext_description
        FROM nce_email_info
        WHERE ncee_email_type = 'E'
    end
    
    return 0

END
GO
GRANT EXECUTE ON  [dbo].[d_get_nc_recipient_sp] TO [public]
GO
