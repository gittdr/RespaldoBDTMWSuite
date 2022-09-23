SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_OttUpdAssignTrlrMonPlanRqstRecs] 
		@RecSN					AS INT,
		@RecStatCode			AS INT,
		@UpdatedBy				AS VARCHAR(20)
							 
AS

-- =============================================================================
-- Stored Proc: tm_OttUpdAssignTrlrMonPlanRqstRecs
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
-- PTS 74557 - VMS - 2013.01.07 - Adding s to end of proc name and deleting previous version.
-- PTS 74557 - VMS - 2014.01.16 - Changing @SN to @RecSN.
-- =============================================================================

BEGIN
	DECLARE @UpdatedOn				AS DATETIME
	SELECT @UpdatedOn = GETDATE()
	----------------------------------------------------------------------------
	-- Verify that the record to modified exists in table tblOttAssignTrailerMonPlanStage
	IF EXISTS( SELECT SN
			    FROM dbo.tblOttAssignTrailerMonPlanStage
			   WHERE SN = @RecSN)
		------------------------------------------------------------------------
		-- Record found for updating
		BEGIN

			UPDATE dbo.tblOttAssignTrailerMonPlanStage
					SET RecStatCode			= @RecStatCode, 
						UpdatedBy			= @UpdatedBy,
						UpdatedOn			= @UpdatedOn
			 WHERE 
					SN = @RecSN

		END

END

GO
GRANT EXECUTE ON  [dbo].[tm_OttUpdAssignTrlrMonPlanRqstRecs] TO [public]
GO
