SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_routesync_getBlobRecords]
AS
-- =============================================================================
--	Stored Proc: [dbo].[tmail_routesync_getBlobRecords]
--	Author     :	Rob Scott
--	Create date: 2013.02.22  - PTS 63996
--	Description:
--
--	Gets RouteSync records ready for processing. 'Ready for processing' is when
--	both lrs_date_sent and lrs_error_date are NULL. Only retrieves the oldest
--	record PER trc_id.
--
--	Change Log:
--		
--		
--
-- =============================================================================
--
--      Input parameters:
--      ------------------------------------------------------------------------
--		None
--
--      Output paramters:
--      ------------------------------------------------------------------------
--		None
--
--      Returns:
--      ------------------------------------------------------------------------
--		Data table containing the routesync records ready for processing as
--		described above.
--
-- =============================================================================

DECLARE @tbl TABLE(	lrs_id				Int,
					lgh_number			Int,
					mov_number			Int,
					mpp_id				Varchar(8),
					trc_id				Varchar(8),
					trl_id				Varchar(13),
					lrs_managed			Char(1),
					lrs_distance		Decimal(4,1),
					lrs_compliance		Int,
					lrs_date_calculated	Datetime,
					lrs_date_sent		Datetime,
					lrs_message			varbinary(max),
					lrs_response_code	int,
					lrs_error_text		varchar(500),
					lrs_error_date		datetime,
					ord_number			char(12),
					lgh_driver1			varchar(8)
					)

---------------------------------------------------------------------------------
-- INSERT ROUTE SYNC RECORDS INTO TABLE VAR SO AS TO NOT BE AFFECTED BY THE
-- SUBSEQUENT SETTING OF THE STATUS TO IN-PROCESS:
---------------------------------------------------------------------------------					
  INSERT @tbl	SELECT		lgh_routesync.lrs_id, lgh_routesync.lgh_number, lgh_routesync.mov_number, lgh_routesync.mpp_id, lgh_routesync.trc_id, 
							lgh_routesync.trl_id, lgh_routesync.lrs_managed, lgh_routesync.lrs_distance, lgh_routesync.lrs_compliance, 
							lgh_routesync.lrs_date_calculated, lgh_routesync.lrs_date_sent, lgh_routesync.lrs_message, lgh_routesync.lrs_response_code, 
							lgh_routesync.lrs_error_text, lgh_routesync.lrs_error_date, case when (orderheader.ord_number IS NULL) THEN 0 ELSE orderheader.ord_number END, legheader.lgh_driver1
					FROM	lgh_routesync INNER JOIN
							legheader ON lgh_routesync.lgh_number = legheader.lgh_number LEFT OUTER JOIN
							orderheader ON legheader.ord_hdrnumber = orderheader.ord_hdrnumber
					WHERE	(lgh_routesync.lrs_id IN (	SELECT MIN(lrs_id) AS Expr1
															FROM lgh_routesync AS lgh_routesync_1
															WHERE (lrs_date_sent IS NULL) AND (lrs_error_date IS NULL) AND (lrs_response_code IS NULL)
															GROUP BY trc_id))
	IF @@ROWCOUNT > 0
		UPDATE lgh_routesync 
		SET lrs_response_code = 999			-- 999 = IN-PROCESS 
		WHERE lrs_id IN (SELECT lrs_id FROM @tbl)

---------------------------------------------------------------------------------
-- RETURN THE TEMP TABLE:
---------------------------------------------------------------------------------
	SELECT * FROM @tbl
GO
GRANT EXECUTE ON  [dbo].[tmail_routesync_getBlobRecords] TO [public]
GO
