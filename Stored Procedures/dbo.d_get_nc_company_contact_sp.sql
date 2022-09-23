SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 
CREATE PROCEDURE [dbo].[d_get_nc_company_contact_sp] 
AS

/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure. Get name and id of all the nc contact group and individual for dropdown list

exec d_get_nc_company_contact_sp 
*/

BEGIN
    select nceg_group_id   contact_id,
           nceg_group_name contact_name,
           'G'             contact_type
     from  dbo.nce_groups
     
    UNION 
    select ncee_email_person_id,   
           ncee_ext_description,
           'I'                    
      from dbo.nce_email_info
     where ncee_email_type = 'E'
    
    UNION      
    select ncee_email_person_id,  
           usr_fname + ' ' + usr_lname ,   
           'I'                    
     from  dbo.nce_email_info
        INNER JOIN dbo.ttsusers ON ncee_int_usr_userid = usr_userid
     where ncee_email_type = 'I'
    
    UNION
    select 0, ' ', 'N'
    
    UNION
    select 0, ' ', 'I'
    
    UNION
    select 0, ' ', 'G'
     
    return 0
END
GO
GRANT EXECUTE ON  [dbo].[d_get_nc_company_contact_sp] TO [public]
GO
