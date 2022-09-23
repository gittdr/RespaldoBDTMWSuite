SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_MakeXMLDestID] 
		@StopCompanyID			AS VARCHAR(8),
		@StopNumber				AS VARCHAR(12)
							 
AS

-- =============================================================================
-- Stored Proc: tm_MakeXMLDestID
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

	DECLARE @WFDestID AS VARCHAR(21)

	-- Initialize the output variables
	SELECT @WFDestID = ''

	-- Perform the desired procedure.
	SELECT @WFDestID = @StopCompanyID + '_' + @StopNumber

	-- Return the results.
	SELECT @WFDestID

END

GO
GRANT EXECUTE ON  [dbo].[tm_MakeXMLDestID] TO [public]
GO
