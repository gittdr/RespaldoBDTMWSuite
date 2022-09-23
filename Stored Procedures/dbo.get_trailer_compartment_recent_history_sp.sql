SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[get_trailer_compartment_recent_history_sp] 
	@trailerId As varchar(13)
AS
BEGIN

DECLARE @compartmentId int
DECLARE @topFiveForAllCompartmentsTable TABLE(
trl_id varchar(13),
tcth_compartment int,
cmd_code varchar(8),
ord_number varchar(12),
fgt_number int,
stp_number int,
stp_status varchar(6),
stp_arrivaldate datetime
)

DECLARE compartmentCursor CURSOR
FOR SELECT DISTINCT trl_det_compartment FROM trailer_detail
WHERE trl_id = @trailerId
ORDER BY trl_det_compartment

OPEN compartmentCursor
FETCH NEXT FROM compartmentCursor INTO @compartmentId

WHILE @@FETCH_STATUS = 0
BEGIN

INSERT INTO @topFiveForAllCompartmentsTable
SELECT TOP 5 header.trl_id, header.tcth_compartment, detail.cmd_code, oh.ord_number, detail.fgt_number, detail.stp_number, recentStops.stp_status, recentStops.stp_arrivaldate FROM TrailerCompartmentTrackingDetail detail
INNER JOIN (SELECT TOP 100 PERCENT s.stp_number, s.stp_arrivaldate, s.stp_status FROM stops s
			INNER JOIN TrailerCompartmentTrackingHeader header ON s.lgh_number = header.lgh_number
			WHERE header.trl_id = @trailerId
			AND header.tcth_compartment = @compartmentId
			ORDER BY s.stp_arrivaldate DESC) recentStops
ON recentStops.stp_number = detail.stp_number
INNER JOIN TrailerCompartmentTrackingHeader header ON header.tcth_id = detail.tcth_id
LEFT JOIN orderheader oh ON oh.ord_hdrnumber = detail.ord_hdrnumber
WHERE header.trl_id = @trailerId
AND header.tcth_compartment = @compartmentId
ORDER BY recentStops.stp_arrivaldate DESC

FETCH NEXT FROM compartmentCursor INTO @compartmentId

END

CLOSE compartmentCursor
DEALLOCATE compartmentCursor

SELECT * FROM @topFiveForAllCompartmentsTable

END
GO
GRANT EXECUTE ON  [dbo].[get_trailer_compartment_recent_history_sp] TO [public]
GO
