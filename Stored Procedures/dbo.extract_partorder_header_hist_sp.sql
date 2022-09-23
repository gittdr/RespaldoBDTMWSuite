SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[extract_partorder_header_hist_sp]
	@p_poh_identity	int
AS	

/**
 * 
 * NAME:
 * extract_partorder_header_hist_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Extracts the partorder Header History based on the specified poh_identity
 *
 * RETURNS: NONE
 *
 * RESULT SETS:  Partorder Header History Information for display in datawindow
 *
 * PARAMETERS:
 * @p_poh_identity	int 	Partorder identity that the procedure will return the history for
 *
 * REVISION HISTORY:
 * 08/29/2005.01 ? PTS - Dan Hudec ? Created Procedure
 *
 **/

BEGIN

SELECT	p.poh_hist_identity,
	p.poh_identity,
	l.name Status, --Status
	p.poh_pickupdate,
	p.poh_deliverdate,
	p.poh_timelineid,
	p.poh_updatedby,
	p.poh_updatedon 
FROM	partorder_header_history AS p 
	INNER JOIN labelfile AS l 
	ON l.abbr = p.poh_status and l.labeldefinition = 'PartOrderStatus'
WHERE	p.poh_identity = @p_poh_identity
ORDER BY p.poh_hist_identity desc

END
GO
GRANT EXECUTE ON  [dbo].[extract_partorder_header_hist_sp] TO [public]
GO
