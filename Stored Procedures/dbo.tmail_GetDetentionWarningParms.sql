SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_GetDetentionWarningParms]
	@stp_number int,
	@AlertMins int out,
	@detstart int out
AS

/**
 * 
 * NAME:
 * dbo.tmail_GetDetentionWarningParms
 *
 * TYPE:
 * StoredProcedure 
 *
 * DESCRIPTION:
 * This procedure determines detention warning method and interval
 *
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @stp_number, int, input
 * 002 - @AlertMins, int, out;
 *		 Detention minutes at which to alert dispatcher.
 * 003 - @detstart, int, out;
 *		 Time from which detention starts.
 *       Valid values are the same as cmp_det_start: 
 *			1 = arrival time; 
 *			2 = the later of arrival and earliest time;
 *			3 = the later of arrival and earliest arrival date/time recorded for the stop's most recent scheduled appointment.
 *
 * REVISION HISTORY:
 * 12/19/2005.01 – PTS31012 - Tim Adam – Clipped from tmail_DetentionPolling.
 *
 **/

SET NOCOUNT ON 

SELECT
	@AlertMins = case stp_type
		when 'PUP' then
		ISNULL(
			ISNULL(
				ISNULL(	
					stops.stp_alloweddet, 
					ISNULL(
						(SELECT MIN(cmp_PUPalert) 
							FROM company (NOLOCK) 
							INNER JOIN orderheader (NOLOCK) ON orderheader.ord_billto = company.cmp_id 
							WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
						(SELECT cmp_PUPalert 
							FROM company (NOLOCK)
							WHERE company.cmp_id = stops.cmp_id))
				),
				(select cast(gi_string1 as int) 
					from generalinfo (NOLOCK)
					where gi_name = 'DetentionPUPMinsAlert') ),
			-1)
		else
		ISNULL(
			ISNULL(
				ISNULL(
					stops.stp_alloweddet, 
					ISNULL(
						(SELECT MIN(cmp_DRPalert) 
							FROM company (NOLOCK)
							INNER JOIN orderheader (NOLOCK) ON orderheader.ord_billto = company.cmp_id 
							WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
						(SELECT cmp_DRPalert 
							FROM company (NOLOCK) 
							WHERE company.cmp_id = stops.cmp_id))
				),
				(select cast(gi_string1 as int) from generalinfo where gi_name = 'DetentionDRPMinsAlert') ),
			-1)
		end,
	@detstart = ISNULL(
		(SELECT MIN(cmp_det_start) 
			FROM company (NOLOCK)
			INNER JOIN orderheader (NOLOCK) ON orderheader.ord_billto = company.cmp_id 
			WHERE orderheader.ord_hdrnumber = stops.ord_hdrnumber), 
		ISNULL(
			(SELECT cmp_det_start 
				FROM company WHERE company.cmp_id = stops.cmp_id),
			0
		)
	)
	FROM stops (NOLOCK)
	WHERE stp_number = @stp_number
GO
GRANT EXECUTE ON  [dbo].[tmail_GetDetentionWarningParms] TO [public]
GO
