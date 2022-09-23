SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_QCWF_MakeXMLStopID]
	@StopSequence AS VARCHAR(8),
	@StopNumber AS VARCHAR(8),
	@CompanyID AS VARCHAR(8)

AS

DECLARE @WFStopID AS VARCHAR(30)

BEGIN
	SET NOCOUNT ON;

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
GRANT EXECUTE ON  [dbo].[tm_QCWF_MakeXMLStopID] TO [public]
GO
