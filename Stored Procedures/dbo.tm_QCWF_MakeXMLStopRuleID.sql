SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_QCWF_MakeXMLStopRuleID]
	@fldWFStopID AS VARCHAR(30)

AS

DECLARE @WFStopRuleID AS VARCHAR(40)

BEGIN
	SET NOCOUNT ON;

	-- Initialize the output variables
	SELECT @WFStopRuleID = ''

	-- Perform the desired procedure.
	SELECT @WFStopRuleID =  @fldWFStopID + '_RULE'

	-- Return the results.
	SELECT @WFStopRuleID

END
GO
GRANT EXECUTE ON  [dbo].[tm_QCWF_MakeXMLStopRuleID] TO [public]
GO
