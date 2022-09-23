SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************************************  
  Object Description:
  This function returns a table containing the arrived and departed flags as well as asset info for all stops on 
  each of the given orders. The initial intended use case was to be able to determine the status of cross-docked 
  orders without loading all of the order's moves into memory.

  Revision History:
  Date         Name             Label/PTS      Description
  -----------  ---------------  -------------  ----------------------------------------
  04/13/2017   Cory Sellers     NSUITE-201079  Initial Release

********************************************************************************************************************/

CREATE FUNCTION [dbo].[GetStopActualizationDataForOrders_fn] (
@orderHdrNumbers TableVarOrdHdrNumberList READONLY
)
RETURNS @actualizationData TABLE(
	orderHeaderNumber int,
	stopNumber int,
	evt_status varchar(6),
	evt_departure_status varchar(6),
	driverId varchar(8),
	tractorId varchar(8),
	carrierId varchar(8))
AS 
BEGIN

	INSERT INTO
		@actualizationData
	SELECT
		evt.ord_hdrnumber, evt.stp_number, evt.evt_status, evt.evt_departure_status, evt.evt_driver1, evt.evt_tractor, evt.evt_carrier
	FROM
		[event] evt
	JOIN
		@orderHdrNumbers ordHdrNums ON ordHdrNums.orderHdrNumber = evt.ord_hdrnumber
	JOIN
		eventcodetable ect ON evt.evt_eventcode = ect.abbr
	WHERE
		ect.primary_event = 'Y'

	RETURN
END

GO
GRANT SELECT ON  [dbo].[GetStopActualizationDataForOrders_fn] TO [public]
GO
