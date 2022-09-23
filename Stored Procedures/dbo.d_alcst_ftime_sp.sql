SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_alcst_ftime_sp] ( @container_id 		VARCHAR (13),		-- 001
									@ord_hdrnumber		INTEGER             -- 002
									)
AS
/**
 *
 * NAME:
 * dbo.d_alcst_ftime_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used as a data source for datawindow d_alcst_ftime
 *
 * RETURNS:
 *
 * RESULT SETS:
 * 001 - VARCHAR(20) Label for field.
 * 002 - DATETIME that free time ends, per PTS 41905.
 *
 * PARAMETERS:
 * 001 - @container_id VARCHAR (13),
 * 002 - @ord_hdrnumber,
 *
 * REVISION HISTORY:
 * MDH  PTS# 39373 Created for All Coast
 * MDH  PTS# 41905 Re-wrote for All Coast.
 **/
BEGIN
	DECLARE	@revtype2		VARCHAR (6)

	SELECT @revtype2	= COALESCE (ord_revtype2,'UNK') 
		FROM orderheader 
		WHERE ord_hdrnumber = @ord_hdrnumber

	IF @revtype2 = 'IMPORT' 
		SELECT CAST ('FTime Expires' AS VARCHAR (20)) display_label, 
				COALESCE (MIN (stp_schdtlatest),'2049-12-31 23:58:00') display_value
		FROM stops join event on (stops.stp_number = event.stp_number)
		WHERE stops.ord_hdrnumber = @ord_hdrnumber 
		  AND event.evt_trailer1 = @container_id
		  AND event.evt_pu_dr = 'PUP'
	ELSE IF @revtype2 = 'EXPORT'
		SELECT CAST ('Cut Off Time' AS VARCHAR (20)) display_label, 
				COALESCE (MIN (stp_schdtlatest),'2049-12-31 23:58:00') display_value
		FROM stops join event on (stops.stp_number = event.stp_number)
		WHERE stops.ord_hdrnumber = @ord_hdrnumber 
		  AND event.evt_trailer1 = @container_id
		  AND stops.stp_number = event.stp_number 
		  AND event.evt_pu_dr = 'DRP'
	ELSE
		SELECT CAST ('' AS VARCHAR (20)) display_label, 
				CAST (NULL AS DATETIME) display_value
		FROM onerow
		
END

GO
GRANT EXECUTE ON  [dbo].[d_alcst_ftime_sp] TO [public]
GO
