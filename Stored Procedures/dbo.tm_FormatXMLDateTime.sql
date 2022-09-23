SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_FormatXMLDateTime] 
		@InputDateTime			AS VARCHAR(40)
							 
AS

-- =============================================================================
-- Stored Proc: tm_FormatXMLDateTime
-- Author     :	From email authored by Lori Brickley to Dave Gudat on April 10, 2013
-- Create date: 2014.03.04
-- Description:
--
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
-- =============================================================================

BEGIN

	SET NOCOUNT ON;
	
	DECLARE @WFOutDateTime AS VARCHAR(40)

	-- Initialize the output variables
	SELECT @WFOutDateTime = ''

	-- Perform the desired procedure.
	 SELECT @WFOutDateTime = 
				REPLACE(CONVERT(VARCHAR(40),CONVERT(DATETIME,@InputDateTime),120),' ','T')

	-- Return the results.
	SELECT @WFOutDateTime

END

GO
GRANT EXECUTE ON  [dbo].[tm_FormatXMLDateTime] TO [public]
GO
