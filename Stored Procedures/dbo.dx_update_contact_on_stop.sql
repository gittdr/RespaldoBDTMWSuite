SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_update_contact_on_stop]
	@ord_number int,
	@stp_number int,
	@stp_contact varchar(30),
	@stp_phonenumber varchar(20)
AS

/*******************************************************************************************************************  
  Object Description:
  dx_update_contact_on_stop

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  04/05/2016   John Richardson               Updated existence check per TMW code standards
********************************************************************************************************************/

update stops
   set stp_contact = isnull(@stp_contact,'')
	 , stp_phonenumber = isnull(@stp_phonenumber,'')
     , skip_trigger = 1
 where ord_hdrnumber = @ord_number
   and stp_number = @stp_number

if @@ROWCOUNT = 1
	return 1
else
	return -1

GO
GRANT EXECUTE ON  [dbo].[dx_update_contact_on_stop] TO [public]
GO
