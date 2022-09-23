SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROCEDURE [dbo].[d_get_non_nc_users_to_nc]
AS

/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure. Get candiates for new nc user.

d_get_non_nc_users_to_nc 

*/

BEGIN

    SELECT ttsusers.usr_userid,   
           ttsusers.usr_lname,   
           ttsusers.usr_fname
      FROM ttsusers  
    WHERE  NOT EXISTS (select 1 from nce_email_info 
                        where ncee_email_type = 'I' and ncee_int_usr_userid = ttsusers.usr_userid )

END

GO
GRANT EXECUTE ON  [dbo].[d_get_non_nc_users_to_nc] TO [public]
GO
