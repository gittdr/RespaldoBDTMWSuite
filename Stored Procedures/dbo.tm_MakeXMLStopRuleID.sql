SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_MakeXMLStopRuleID] 
	@fldWFStopID	AS VARCHAR(30)
							 
AS

-- =============================================================================
-- Stored Proc: tm_MakeXMLStopRuleID
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

	DECLARE @WFStopRuleID AS VARCHAR(40)

	-- Initialize the output variables
	SELECT @WFStopRuleID = ''

	-- Perform the desired procedure.
	SELECT @WFStopRuleID =  @fldWFStopID + '_RULE'

	-- Return the results.
	SELECT @WFStopRuleID

END

GO
GRANT EXECUTE ON  [dbo].[tm_MakeXMLStopRuleID] TO [public]
GO
