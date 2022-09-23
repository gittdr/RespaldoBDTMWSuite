SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE PROCEDURE [dbo].[get_ttsuser_email_address_sp]  
(
    @userid varchar(20), 
    @address varchar(255) out
)
AS

/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure. Get email address for the given ttsuser.
TGRIFFIT 42167 06/12/2008 changed datatype of @userid from varchar(8) to char(20) to match usr_userid.

exec get_ttsuser_email_address_sp 'NNIU'

*/


BEGIN

    select @address = null
    
    select @address = usr_mail_address
    from ttsusers 
    where usr_userid = @userid
    
    return 0

END
GO
GRANT EXECUTE ON  [dbo].[get_ttsuser_email_address_sp] TO [public]
GO
