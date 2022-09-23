SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[tm_OttGetPingTrailerStageRecs]	
		
AS

-- =============================================================================
-- Stored Proc: tm_OttGetPingTrailerStageRecs
-- Author     :	Sensabaugh, Virgil
-- Create date: 2014.05.12
-- Description:
--      This procedure will pull records from table tblOttPingTableStage
--      which have not been processed.
--      
--      Outputs:
--      ------------------------------------------------------------------------
--      Result set containing the applicable records.
--
--      Input parameters:
--      ------------------------------------------------------------------------
--		None
--
-- =============================================================================
-- Modification Log:
-- PTS 77420 - VMS - 2014.05.12 - New
-- 
-- =============================================================================
-- Used for testing proc >>  EXEC tm_OttGetPingTrailerStageRecs
-- =============================================================================

BEGIN 

	SELECT 
		ISNULL(SN, '') SN,
		ISNULL(TrailerID, '') TrailerID,
		ISNULL(TrailerSCAC, '') TrailerSCAC,
		ISNULL(RecStatCode, '') RecStatCode,
		ISNULL(CreatedOn, '2049-12-31') CreatedOn,
		ISNULL(CreatedBy, '') CreatedBy,
		ISNULL(UpdatedOn, '2049-12-31') UpdatedOn,
		ISNULL(UpdatedBy, '') UpdatedBy
	FROM tblOttPingTrailerStage (NOLOCK)
	WHERE RecStatCode < 1

END	

GO
GRANT EXECUTE ON  [dbo].[tm_OttGetPingTrailerStageRecs] TO [public]
GO
