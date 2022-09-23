SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[extract_partorder_detail_hist_sp]
	@p_poh_identity	int
AS	

/**
 * 
 * NAME:
 * extract_partorder_detail_hist_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Extracts the partorder Detail History based on the specified poh_identity
 *
 * RETURNS: NONE
 *
 * RESULT SETS:  Partorder Detail History Information for display in datawindow
 *
 * PARAMETERS:
 * @p_poh_identity	int 	Partorder identity that the procedure will return the history for
 *
 * REVISION HISTORY:
 * 08/29/2005.01 ? PTS - Dan Hudec ? Created Procedure
 *
 **/

BEGIN

SELECT 	p.pod_hist_identity,
	p.pod_group_identity,
	p.pod_identity,
	p.poh_identity,
	p.pod_partnumber,
	p.pod_originalcount,
	p.pod_originalcontainers,
	p.pod_adjustedcount,
	p.pod_adjustedcontainers,
	p.pod_pu_count,
	p.pod_pu_containers,
	p.pod_cur_count,
	p.pod_cur_containers,
	l.name Status, --Status
	p.pod_updatedby,
	p.pod_updatedon
FROM 	partorder_detail_history AS p INNER JOIN labelfile as L ON
	l.labeldefinition = 'PartOrderStatus' and l.abbr = p.pod_status
WHERE	p.poh_identity = @p_poh_identity
ORDER BY p.pod_group_identity desc, p.pod_identity

END
GO
GRANT EXECUTE ON  [dbo].[extract_partorder_detail_hist_sp] TO [public]
GO
