SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[tm_OttGetOnePingTrailerStageRecs]	
		@TrailerID			AS VARCHAR(20),
		@TrailerSCAC		AS VARCHAR(4),
		@ResponseDate		AS DATETIME

AS

-- =============================================================================
-- Stored Proc: tm_OttGetOnePingTrailerStageRecs
-- Author     :	Sensabaugh, Virgil
-- Create date: 2014.05.12
-- Description:
--      This procedure will pull one record from table tblOttPingTableStage
--      which should represent the record created for the ping request to be made.
--      
--      Outputs:
--      ------------------------------------------------------------------------
--      Result set containing the applicable record.
--
--      Input parameters:
--      ------------------------------------------------------------------------
--		None
--		001		@TrailerID			AS VARCHAR(20)
--		002		@TrailerSCAC		AS VARCHAR(4)
--		003		@ResponseDate		AS DATETIME
--
-- =============================================================================
-- Modification Log:
-- PTS 77420 - VMS - 2014.05.12 - New
-- 
-- =============================================================================
-- Used for testing proc >>  EXEC tm_OttGetOnePingTrailerStageRecs '', '', ''
-- =============================================================================

BEGIN 

	SELECT TOP 1
		ISNULL(SN, '') SN,
		ISNULL(TrailerID, '') TrailerID,
		ISNULL(TrailerSCAC, '') TrailerSCAC,
		ISNULL(RecStatCode, '') RecStatCode,
		ISNULL(CreatedOn, '2049-12-31') CreatedOn,
		ISNULL(CreatedBy, '') CreatedBy,
		ISNULL(UpdatedOn, '2049-12-31') UpdatedOn,
		ISNULL(UpdatedBy, '') UpdatedBy
	FROM tblOttPingTrailerStage (NOLOCK)
	WHERE	TrailerID = @TrailerID
	AND		TrailerSCAC = @TrailerSCAC
	AND		RecStatCode = 2		-- 2 means staging request has been sent to Omnitracs.
	AND		UpdatedOn < @ResponseDate
	ORDER BY UpdatedOn DESC

END	

GO
GRANT EXECUTE ON  [dbo].[tm_OttGetOnePingTrailerStageRecs] TO [public]
GO
