SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[d_get_email_info_from_gi]
AS

/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure. Gets Non-conformance email sender info.

exec d_get_email_info_from_gi

*/

select gi_string1 as 'Subject',
       gi_string2 as 'Sender_Address',
       gi_string3 as 'Sender_Name'
from generalinfo
where upper(gi_name) = 'EMAIL_INFO'

GO
GRANT EXECUTE ON  [dbo].[d_get_email_info_from_gi] TO [public]
GO
