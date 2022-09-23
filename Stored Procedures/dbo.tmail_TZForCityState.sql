SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_TZForCityState] 
		@cty					AS VARCHAR(18), 
		@st						AS VARCHAR(8)
							 
AS

--tmail_TZForCityState 'cleveland','oh'

-- =============================================================================
-- Stored Proc: tmail_TZForCityState
-- Author     :	From email authored by Lori Brickley to Dave Gudat on April 10, 2013
-- Create date: 2014.03.04
-- Description:
--      
--      Outputs:
--      ------------------------------------------------------------------------
--
--      Input parameters:
--      ------------------------------------------------------------------------
--
-- =============================================================================
-- Modification Log:
-- PTS 74198 - VMS - 2014.03.04 - Adding this stored proc to my database
-- PTS 99031 - DL - 2016.05.26 - Fixing for minutes
-- =============================================================================

BEGIN
	SET NOCOUNT ON;
	
	DECLARE @DSTDelta INT
	SET @DSTDelta = CASE dbo.InDST (GETDATE(),'0') WHEN 'Y' THEN 1 ELSE 0 END

	SELECT 
	CASE WHEN FLOOR(cty_GMTDelta) <> CEILING(cty_GMTDelta)
	THEN
		CASE WHEN cty_GMTDelta < 0 THEN '' ELSE '-' END + 
		RIGHT ('00' + CAST((FLOOR(cty_GMTDelta) - (@DSTDelta * CASE WHEN FLOOR(cty_GMTDelta) < 0 THEN -1 ELSE 1 END)) AS VARCHAR(2)), 2) +
		':' + RIGHT ('00' + CAST((cty_GMTDelta - FLOOR(cty_GMTDelta)) * 60 AS VARCHAR(2)), 2)
	ELSE
		CASE WHEN cty_GMTDelta < 0 THEN '' ELSE '-' END + 
		RIGHT ('00' + CAST((cty_GMTDelta - (@DSTDelta * CASE WHEN cty_GMTDelta < 0 THEN -1 ELSE 1 END)) AS VARCHAR(2)), 2) +
		':' + RIGHT ('00' + CAST(cty_TZMins AS VARCHAR(2)), 2)
	END
	FROM city (NOLOCK)
	WHERE cty_name = @cty AND cty_state = @st
END

GO
GRANT EXECUTE ON  [dbo].[tmail_TZForCityState] TO [public]
GO
