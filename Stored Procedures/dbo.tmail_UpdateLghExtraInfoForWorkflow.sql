SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[tmail_UpdateLghExtraInfoForWorkflow] (@lgh varchar(20), @WFStatus varchar(15))

AS

/*
Purpose:  Sets the current Workflow status of the Leg
Revision History:
Created - LB - 12/5/2013

*/

IF @WFStatus NOT in ('PrePlan','TripPlan','')
BEGIN
	RAISERROR ('Invalid Workflow Status: %s.', 16, 1, @WFStatus)
	RETURN
END

UPDATE Legheader
SET lgh_extrainfo3 = @WFStatus
WHERE lgh_number = @lgh

GO
GRANT EXECUTE ON  [dbo].[tmail_UpdateLghExtraInfoForWorkflow] TO [public]
GO
