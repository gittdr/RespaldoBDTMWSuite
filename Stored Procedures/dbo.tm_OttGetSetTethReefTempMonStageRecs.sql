SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_OttGetSetTethReefTempMonStageRecs]	
		
AS

-- =============================================================================
-- Stored Proc: tm_OttGetSetTethReefTempMonStageRecs
-- Author     :	Sensabaugh, Virgil
-- Create date: 2013.10.02
-- Description:
--      This procedure will pull records from table tblOttSetTethReefTempMonStage
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
-- Used for testing proc >>  EXEC tm_OttGetSetTethReefTempMonStageRecs
/*
Used for testing proc
EXEC tm_OttGetSetTethReefTempMonStageRecs
*/
-- =============================================================================

BEGIN 

SELECT 
	ISNULL(SN, '') SN,
	ISNULL(TrailerID, '') TrailerID,
	ISNULL(TrailerSCAC, '') TrailerSCAC,
	ISNULL(TethReefMonActive, '') TethReefMonActive,
	ISNULL(TethReefMonTargetTemp, '') TethReefMonTargetTemp,
	ISNULL(TethReefMonTempTolerance, '') TethReefMonTempTolerance,
	ISNULL(RecStatCode, '') RecStatCode,
	ISNULL(CreatedOn, '2049-12-31') CreatedOn,
	ISNULL(CreatedBy, '') CreatedBy,
	ISNULL(UpdatedOn, '2049-12-31') UpdatedOn,
	ISNULL(UpdatedBy, '') UpdatedBy
FROM tblOttSetTethReefTempMonStage (NOLOCK)
WHERE RecStatCode < 1

END	

GO
GRANT EXECUTE ON  [dbo].[tm_OttGetSetTethReefTempMonStageRecs] TO [public]
GO
