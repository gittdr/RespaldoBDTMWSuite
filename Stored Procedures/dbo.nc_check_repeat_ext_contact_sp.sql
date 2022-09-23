SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[nc_check_repeat_ext_contact_sp] 
(
    @name varchar(255), 
    @result char(1) out
)
AS

/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure. Check if the input name already exists in the external contact list.

declare @r char(1)
exec nc_check_repeat_ext_contact_sp 'Bob Beach 1', @r

*/

BEGIN

    If exists ( SELECT 1 FROM nce_email_info 
                 WHERE ncee_email_type = 'E' and upper(ncee_ext_description) = upper(@name) )
        select @result = 'Y'
    Else
        select @result = 'N'
    
    return 0
    
END
GO
GRANT EXECUTE ON  [dbo].[nc_check_repeat_ext_contact_sp] TO [public]
GO
