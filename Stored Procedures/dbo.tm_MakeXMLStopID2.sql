SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_MakeXMLStopID2] 
	@StopSequence	AS VARCHAR(8),
	@StopNumber		AS VARCHAR(8),
	@CompanyID		AS VARCHAR(8)
							 
AS

-- =============================================================================
-- Stored Proc: tm_MakeXMLStopID2
-- Author     :	Virgil Sensabaugh
-- Create date: 2014.11.11
-- Description: Replaces tm_MakeXMLStopID.  Old version kept in source for clients
--              who may be using the proc in their workflow forms.
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
-- PTS 83368 - VMS - 2014.11.11 - Created
-- =============================================================================

BEGIN

	SET NOCOUNT ON;

	DECLARE @WFStopID AS VARCHAR(30)

	-- Initialize the output variables.
	SELECT @WFStopID = ''

	-- Perform the desired procedure.
	SELECT @WFStopID = CONVERT(VARCHAR(8),@StopSequence) + '_' + 
                       CONVERT(VARCHAR(8),@StopNumber) + '_' + 
                       @CompanyID

	-- Return the results.
	SELECT @WFStopID

END

GO
GRANT EXECUTE ON  [dbo].[tm_MakeXMLStopID2] TO [public]
GO
