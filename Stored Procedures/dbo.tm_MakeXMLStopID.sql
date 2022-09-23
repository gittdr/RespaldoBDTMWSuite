SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_MakeXMLStopID] 
	@StopSequence	AS VARCHAR(8),
	@StopNumber		AS VARCHAR(8),
	@CompanyID		AS VARCHAR(8),
	@parm4 as varchar(50),
	@parm5 as varchar(50),
	@parm6 as varchar(50)
							 
AS

-- =============================================================================
-- Stored Proc: tm_MakeXMLStopID
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

	DECLARE @WFStopID AS VARCHAR(30)

	-- Initialize the output variables.
	SELECT @WFStopID = ''

	-- Perform the desired procedure.
	SELECT @WFStopID = CONVERT(VARCHAR(8),@StopSequence) + '_' + 
                       CONVERT(VARCHAR(8),@StopNumber) + '_' + 
                       @CompanyID

	-- Return the results.
	SELECT @WFStopID, @parm6

END

GO
GRANT EXECUTE ON  [dbo].[tm_MakeXMLStopID] TO [public]
GO
