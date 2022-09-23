SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_routesync_getSentRecsWaitingForAStatus_Omnitracs] 
AS
-- =============================================================================
--	Stored Proc: [dbo].[tmail_routesync_getSentRecsWaitingForAStatus_Omnitracs]
--	Author:	Rob Scott
--	Create date: 2013.12.05  - PTS 71605
--
--	Description:
--	For OmniTracsRouteSync - Gets RouteSync records that have been successfully 
--	sent to the OmniTracs EIP web service but have not yet recieved a unit-delivery 
--	status back from the service.
--	
--		lrs_status:
--        AWAITING_DELIVERY_STATUS = 2
--        DELIVERY_STATUS_PENDING = 4
--        DELIVERY_STATUS_SUCCESSFUL = 8
--        DELIVERY_STATUS_FAILED = 16
--        WS_SEND_FAILED = 32
--        COMPLETE_READYFORPURGE = 32768
--
--	Change Log:
--		
--
-- =============================================================================
--
--      Input parameters:
--      ------------------------------------------------------------------------
--		None
--
--      Output parameters:
--      ------------------------------------------------------------------------
--		None
--
--      Returns:
--      ------------------------------------------------------------------------
--		Data table containing the records as described above
--
-- =============================================================================
DECLARE @AWAITING_DELIVERY_STATUS INT,
        @DELIVERY_STATUS_PENDING INT,
        @DELIVERY_STATUS_SUCCESSFUL INT,
        @DELIVERY_STATUS_FAILED INT,
        @WS_SEND_FAILED INT, 
        @COMPLETE_READYFORPURGE INT
					
SET @AWAITING_DELIVERY_STATUS = 2
SET @DELIVERY_STATUS_PENDING = 4
SET @DELIVERY_STATUS_SUCCESSFUL = 8
SET @DELIVERY_STATUS_FAILED = 16
SET @WS_SEND_FAILED = 32
SET @COMPLETE_READYFORPURGE = 32768

---------------------------------------------------------------------------------
-- INSERT ROUTE SYNC RECORDS INTO TABLE VAR SO AS TO NOT BE AFFECTED BY THE
-- SUBSEQUENT SETTING OF THE STATUS TO IN-PROCESS:
---------------------------------------------------------------------------------					
SELECT	lgh_routesync.lrs_id, 
		lgh_routesync.lgh_number, 
		lgh_routesync.mov_number, 
		lgh_routesync.mpp_id, 
		lgh_routesync.trc_id, 
		lgh_routesync.trl_id, 
		lgh_routesync.lrs_managed, 
		lgh_routesync.lrs_distance, 
		lgh_routesync.lrs_compliance, 
		lgh_routesync.lrs_date_calculated, 
		lgh_routesync.lrs_date_sent, 
		lgh_routesync.lrs_message, 
		lgh_routesync.lrs_response_code, 
		lgh_routesync.lrs_error_text, 
		lgh_routesync.lrs_error_date, 
		lgh_routesync.lrs_omnitracs_key,
		orderheader.ord_number, 
		legheader.lgh_driver1
FROM	lgh_routesync INNER JOIN
			legheader ON lgh_routesync.lgh_number = legheader.lgh_number INNER JOIN
			orderheader ON legheader.ord_hdrnumber = orderheader.ord_hdrnumber
WHERE	(lgh_routesync.lrs_error_date IS NULL) AND 
		(lgh_routesync.lrs_date_sent IS NOT NULL) AND 
		(lgh_routesync.lrs_omnitracs_key IS NOT NULL) AND
		(lgh_routesync.lrs_status & @AWAITING_DELIVERY_STATUS > 0) AND
		(lgh_routesync.lrs_status & @COMPLETE_READYFORPURGE = 0)

GO
GRANT EXECUTE ON  [dbo].[tmail_routesync_getSentRecsWaitingForAStatus_Omnitracs] TO [public]
GO
