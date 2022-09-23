SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_QCWF_MakeXMLDestID]
	@StopCompanyID AS VARCHAR(8),
	@StopNumber AS VARCHAR(12)

AS

DECLARE @WFDestID AS VARCHAR(21)

BEGIN
	SET NOCOUNT ON;

	-- Initialize the output variables
	SELECT @WFDestID = ''

	-- Perform the desired procedure.
	SELECT @WFDestID = @StopCompanyID + '_' + @StopNumber

	-- Return the results.
	SELECT @WFDestID

END
GO
GRANT EXECUTE ON  [dbo].[tm_QCWF_MakeXMLDestID] TO [public]
GO
