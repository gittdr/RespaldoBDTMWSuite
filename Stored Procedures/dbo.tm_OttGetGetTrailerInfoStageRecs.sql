SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_OttGetGetTrailerInfoStageRecs]	
		
AS

-- =============================================================================
-- Stored Proc: tm_OttGetGetTrailerInfoStageRecs
-- Author     :	Sensabaugh, Virgil
-- Create date: 2013.09.19
-- Description:
--      This procedure will pull records from the GetTrailerInfoStage table which
--      have not been porcessed .
--      
--      Outputs:
--      ------------------------------------------------------------------------
--      Result set containing the applicable recrods.
--
--      Input parameters:
--      ------------------------------------------------------------------------
--		None
--
-- Used for testing proc >>  EXEC tm_OttGetGetTrailerInfoStageRecs
/*
Used for testing proc
EXEC tm_OttGetGetTrailerInfoStageRecs
*/
-- =============================================================================

BEGIN 

SELECT 
	ISNULL(SN, '') SN, 
	ISNULL(TrailerID, '') TrailerID,
	ISNULL(TrailerSCAC, '') TrailerSCAC, 
	ISNULL(RecStatCode, 9) RecStatCode,
	ISNULL(CreatedOn, '2049-12-31') CreatedOn,
	ISNULL(CreatedBy, '') CreatedBy,
	ISNULL(UpdatedOn, '2049-12-31') UpdatedOn,
	ISNULL(UpdatedBy, '') UpdatedBy
FROM tblOttGetTrailerInfoStage (NOLOCK)
WHERE RecStatCode < 1

END	

GO
GRANT EXECUTE ON  [dbo].[tm_OttGetGetTrailerInfoStageRecs] TO [public]
GO
