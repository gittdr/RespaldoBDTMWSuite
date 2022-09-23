SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_OttGetAssignTrlrMonPlanStageRecs]	
		
AS

-- =============================================================================
-- Stored Proc: tm_OttGetAssignTrlrMonPlanStageRecs
-- Author     :	Sensabaugh, Virgil
-- Create date: 2013.10.02
-- Description:
--      This procedure will pull records from table tblOttAssignTrailerMonPlanStage
--      which have not been pprocessed.
--      
--      Outputs:
--      ------------------------------------------------------------------------
--      Result set containing the applicable records.
--
--      Input parameters:
--      ------------------------------------------------------------------------
--		None
--
-- Used for testing proc >>  EXEC tm_OttGetAssignTrlrMonPlanStageRecs
/*
Used for testing proc
EXEC tm_OttGetAssignTrlrMonPlanStageRecs
*/
-- =============================================================================

BEGIN 

SELECT 
	ISNULL(SN, '') SN,
	ISNULL(TrailerID, '') TrailerID,
	ISNULL(TrailerSCAC, '') TrailerSCAC, 
	ISNULL(MonitoringPlanId, '') MonitoringPlanId,
	ISNULL(RecStatCode, '') RecStatCode,
	ISNULL(CreatedOn, '2049-12-31') CreatedOn,
	ISNULL(CreatedBy, '') CreatedBy,
	ISNULL(UpdatedOn, '2049-12-31') UpdatedOn,
	ISNULL(UpdatedBy, '') UpdatedBy
FROM tblOttAssignTrailerMonPlanStage (NOLOCK)
WHERE RecStatCode < 1

END	

GO
GRANT EXECUTE ON  [dbo].[tm_OttGetAssignTrlrMonPlanStageRecs] TO [public]
GO
