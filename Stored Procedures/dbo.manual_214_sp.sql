SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[manual_214_sp]
@status_code varchar(3),
@cmp_id varchar(8),
@cmp_type varchar(1)

AS

DECLARE @e214_id integer,
	@billto_flag varchar(1),
	@shipper_flag varchar(1),
	@consignee_flag varchar(1),
	@orderby_flag varchar(1),
	@notification_type varchar(1)

select 	@notification_type = gi_string1
from   	generalinfo
where  	gi_name = 'EDI_Notification_Process_Type'

If (@notification_type = '1') Return 1
Else
BEGIN
	select 	@e214_id = IsNull(e214_id, '0')
	from 	edi_214_profile
	where	e214_cmp_id = @cmp_id AND
		charindex(@status_code, e214_edi_status) > 0

	Select 	@billto_flag = IsNull(billto_role_flag, 'N'),
		@shipper_flag = IsNull(shipper_role_flag, 'N'),
		@consignee_flag = IsNull(consignee_role_flag, 'N'),
		@orderby_flag = IsNull(orderby_role_flag, 'N')
	from	edi_214_profile
	where	e214_id = @e214_id

	If (@cmp_type = 'B' and @billto_flag = 'Y') Return 1
	If (@cmp_type = 'B' and @billto_flag = 'N') Return 0
	If (@cmp_type = 'S' and @shipper_flag = 'Y') Return 1
	If (@cmp_type = 'S' and @shipper_flag = 'N') Return 0
	If (@cmp_type = 'C' and @consignee_flag = 'Y') Return 1
	If (@cmp_type = 'C' and @consignee_flag = 'N') Return 0
	If (@cmp_type = 'O' and @orderby_flag = 'Y') Return 1
	If (@cmp_type = 'O' and @orderby_flag = 'N') Return 0
END

GO
GRANT EXECUTE ON  [dbo].[manual_214_sp] TO [public]
GO
