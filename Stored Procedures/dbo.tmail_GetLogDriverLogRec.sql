SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_GetLogDriverLogRec]
	@MppID					AS VARCHAR(8),
	@LogDate				AS DATETIME

AS

-- =============================================================================
-- Stored Proc: GetLogDriverLogRec
-- Author     :	Sensabaugh, Virgil
-- Create date: 2014.04.25
-- Description:
--      
--
--      
--      Outputs:
--      ------------------------------------------------------------------------
--      Result set containing the applicable record.
--
--      Input parameters:
--      ------------------------------------------------------------------------
--		001 - @MppID			VARCHAR(13)
--		002 - @LogDate			DATETIME
--		
--		History:
--      ------------------------------------------------------------------------
--		001 - Abdullah Binghunaiem: Add date casting on the date comparision to 
--				only compare dates.
/*
-- Used for testing proc
-- EXEC tmail_GetLogDriverLogRec '', ''
*/
-- =============================================================================

BEGIN

	SELECT 
			*
	  FROM
			dbo.log_driverlogs (NOLOCK)
	 WHERE
			mpp_id = @mppid	
	    AND
			CAST(log_date AS DATE) = CAST(@LogDate AS DATE)

END

GO
GRANT EXECUTE ON  [dbo].[tmail_GetLogDriverLogRec] TO [public]
GO
