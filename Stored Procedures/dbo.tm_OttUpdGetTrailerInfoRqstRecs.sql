SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_OttUpdGetTrailerInfoRqstRecs] 
		@RecSN					AS INT,
		@RecStatCode			AS INT,
		@UpdatedBy				AS VARCHAR(20)
							 
AS

-- =============================================================================
-- Stored Proc: tm_OttUpdGetTrailerInfoRqstRecs
-- Author     :	Sensabaugh, Virgil
-- Create date: 2013.10.02
-- Description:
--      This procedure will update the web service request record in the
--      tblOttGetTrailerInfoStage to the status passed in.
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
	-- Verify that the record to modified exists in table tblOttGetTrailerInfoStage
	IF EXISTS( SELECT SN
			    FROM dbo.tblOttGetTrailerInfoStage
			   WHERE SN = @RecSN)
		------------------------------------------------------------------------
		-- Record found for updating
		BEGIN

			UPDATE dbo.tblOttGetTrailerInfoStage
					SET RecStatCode			= @RecStatCode, 
						UpdatedBy			= @UpdatedBy,
						UpdatedOn			= @UpdatedOn
			 WHERE 
					SN = @RecSN

		END

END

GO
GRANT EXECUTE ON  [dbo].[tm_OttUpdGetTrailerInfoRqstRecs] TO [public]
GO
