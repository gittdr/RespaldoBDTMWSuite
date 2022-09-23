SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_QCWF_MakeXMLDestType]
	@StopEventType AS VARCHAR(8)

AS

DECLARE @WFDestType AS VARCHAR(20)

BEGIN
	SET NOCOUNT ON;

	-- Initialize the output variables
	SELECT @WFDestType = ''

	-- Perform the desired procedure.
	SELECT @WFDestType = 
				CASE
					WHEN UPPER(@StopEventType) = 'PUP' THEN 'interlinePickup'
					ELSE 'interlineDropoff'
				END

	-- Return the results.
	SELECT @WFDestType

END
GO
GRANT EXECUTE ON  [dbo].[tm_QCWF_MakeXMLDestType] TO [public]
GO
