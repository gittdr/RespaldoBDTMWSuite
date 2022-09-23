SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================================================
-- Stored Proc: [dbo].[tmail_GetMppIdFromMppOtherId]
-- Author     :	Sensabaugh, Virgil
-- Create date: 2013.05.13
-- Description:
--      This procedure will retrieve the mpp_id for the mpp_otherid supplied. 
--      
--      Input parameters:
--      ------------------------------------------------------------------------
--		001 - @mpp_otherId			VARCHAR(12)
--
--      Outputs:
--      ------------------------------------------------------------------------
--		001 - mpp_id				INT
--
--	PARAMETERS:
--	001 - @mpp_otherId				VARCHAR(12)
--	
--	001 - mpp_id					INT
--  ===========================================================================
/*
Used for testing proc
EXEC tmail_GetMppIdFromMppOtherId
'QUALCOMM'

*/
-- =============================================================================

CREATE PROCEDURE [dbo].[tmail_GetMppIdFromMppOtherId]
	@mpp_otherid					VARCHAR(25)

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED -- DIRTY READS FOR ALL TABLES IN THIS TRANSACTION Or REM this line and use (NOLOCK)

BEGIN

    ----------------------------------------------------------------------------
	-- Pull the manpowerprofile record using mpp_otherid.
	 		
	SELECT mpp_id, mpp_otherid from manpowerprofile
	WHERE mpp_otherid = @mpp_otherid 
	
END 

GO
GRANT EXECUTE ON  [dbo].[tmail_GetMppIdFromMppOtherId] TO [public]
GO
