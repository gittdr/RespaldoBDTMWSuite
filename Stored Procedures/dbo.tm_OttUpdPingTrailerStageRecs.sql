SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[tm_OttUpdPingTrailerStageRecs] 
		@RecSN					AS INT,
		@RecStatCode			AS INT,
		@UpdatedBy				AS VARCHAR(20)
							 
AS

-- =============================================================================
-- Stored Proc: tm_OttUpdPingTrailerStageRecs
-- Author     :	Sensabaugh, Virgil
-- Create date: 2013.10.02
-- Description:
--      This procedure will update the web service request record in the
--      tblOttAssignTrailerMonPlanStage to the status passed in.
--      
--      Outputs:
--      ------------------------------------------------------------------------
--      None
--
--      Input parameters:
--      ------------------------------------------------------------------------
--		001 - @RecSN				AS INT,
--		002 - @RecStatCode			AS INT,
--		003 - @UpdatedBy			AS VARCHAR(20)
--
-- =============================================================================
-- Modification Log:
-- PTS 77420 - VMS - 2014.05.12 - New
-- 
-- =============================================================================

BEGIN
	DECLARE @UpdatedOn				AS DATETIME
	SELECT @UpdatedOn = GETDATE()
	----------------------------------------------------------------------------
	-- Verify that the record to modified exists in table tblOttPingTrailerStage
	-- - If it does not exist just fall through.  This is a staging table.
	--   The record may have been deleted in mid process.  Should rarely happen.
	IF EXISTS( SELECT SN
			    FROM dbo.tblOttPingTrailerStage
			   WHERE SN = @RecSN)
		------------------------------------------------------------------------
		-- Record found for updating
		BEGIN

			UPDATE dbo.tblOttPingTrailerStage
					SET RecStatCode			= @RecStatCode, 
						UpdatedBy			= @UpdatedBy,
						UpdatedOn			= @UpdatedOn
			 WHERE 
					SN = @RecSN

		END

END

GO
GRANT EXECUTE ON  [dbo].[tm_OttUpdPingTrailerStageRecs] TO [public]
GO
