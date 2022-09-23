SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_event_code]	@sEvent varchar(50), 
											@sFlags varchar(12)

AS

BEGIN

/*
pass:
	@sEvent = Event to find
return:
	Event Code information

*/

SELECT	[name], 
		abbr [Event], 
		code, 
		locked, 
		userlabelname, 
		edicode, 
		mile_typ_to_stop, 
		mile_typ_from_stop, 
		drv_pay_event, 
		fuel_tax_event, 
		fgt_event, 
		mfh_status_event, 
		lgh_status_event, 
		primary_event, 
		other_event, 
		trl_event, 
		ect_payondepart,
		ect_trlstart, 
		ect_trlend, 
		ect_billable, 
		ect_trcdrv_event, 
		ect_cmdcty_req, 
		ect_retired, 
		ect_purchase_service
	FROM EventCodeTable (NOLOCK)
	WHERE Abbr = @sEvent

END

GO
GRANT EXECUTE ON  [dbo].[tmail_get_event_code] TO [public]
GO
